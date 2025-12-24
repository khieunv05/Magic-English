<?php

namespace Modules\User\Http\Controllers;

use App\Jobs\Auth\SendPasswordResetEmailJob;
use Throwable;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Password;
use Illuminate\Database\QueryException;
use Illuminate\Database\UniqueConstraintViolationException;

use App\Models\User;

use App\Jobs\Auth\SendVerifyEmailOtpJob;
use App\Jobs\Auth\SendWelcomeEmailJob;
use App\Services\Google\GmailService;

use App\Mail\VerifyEmailOtpMail;
use App\Mail\ForgotPasswordMail;
use App\Mail\UserRegisteredMail;

use Modules\User\Http\Requests\Authenticate\LoginRequest;
use Modules\User\Http\Requests\Authenticate\RegisterRequest;
use Modules\User\Http\Requests\User\ChangePasswordRequest;

class AuthController extends \App\Http\Controllers\Controller
{
    /** TTL OTP (phút) */
    protected int $otpTtlMinutes = 10;

    /** Số lần thử tối đa trước khi khoá OTP hiện tại */
    protected int $maxVerifyAttempts = 5;

    /** Throttle resend OTP (giây) */
    protected int $resendCooldownSeconds = 60;

    public function register(RegisterRequest $request): JsonResponse
    {
        try {
            // Prepare username: use given or generate unique from name/email
            $rawUsername = trim((string) $request->input('username'));
            $email = strtolower(trim($request->input('email')));
            $base = $rawUsername !== '' ? $rawUsername : (\Illuminate\Support\Str::slug((string) ($request->input('name') ?: explode('@', $email)[0])) ?: 'user');
            $candidate = $base;
            $i = 1;
            while ($candidate !== '' && User::where('username', $candidate)->exists()) {
                $candidate = $base . $i;
                $i++;
                if ($i > 50) { // avoid infinite loop
                    $candidate = $base . '-' . substr(Str::random(4), 0, 4);
                    break;
                }
            }

            $user = User::create([
                'name' => $request->input('name'),
                'username' => $candidate ?: null,
                'email' => $request->input('email'),
                'password' => Hash::make($request->input('password')),
                'code' => Str::random(20),
                'status' => User::ACTIVE,
                'is_staff' => User::IS_USER,
                'description' => 'Registered via ' . $request->input('contact_method'),
                'heard_from' => $request->input('heard_from'),
            ]);

            // Xác minh email ngay khi đăng ký
            $user->email_verified_at = Carbon::now();
            $user->email_verification_code = null;
            $user->email_verification_expires_at = null;
            $user->email_verification_attempts = 0;
            $user->save();

            return $this->apiResponse(true, 'Your registration was successful. Email verified.', [
                'user_id' => $user->id,
                'email' => $user->email,
                'verified' => true,
            ]);
        } catch (UniqueConstraintViolationException $e) {
            $msg = strtolower($e->getMessage());
            if (str_contains($msg, 'email') || str_contains($msg, 'users_email_unique')) {
                return $this->apiResponse(false, 'This email has already been taken.');
            }
            return $this->apiResponse(false, 'This account information is already used.');
        } catch (QueryException $e) {
            $msg = strtolower($e->getMessage());

            if (str_contains($msg, 'users_email_unique') || str_contains($msg, 'for key `users_email_unique`')) {
                return $this->apiResponse(false, 'This email has already been taken.');
            }
            return $this->apiResponse(true, 'Đăng ký thành công.');
        } catch (Throwable $e) {
            logger($e);
            return $this->apiResponse(false, 'An error occurred while registering.');
        }
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $email = strtolower(trim($request->input('email')));
        $password = (string) $request->input('password');

        $user = User::where('email', $email)->first();
        if (!$user || !Hash::check($password, $user->password)) {
            return $this->apiResponse(false, 'Incorrect login information.');
        }


        if ($user->status !== User::ACTIVE) {
            return $this->apiResponse(false, match ($user->status) {
                User::PENDING => 'Your registration is pending approval. Please wait for confirmation.',
                User::INACTIVE => 'Your account is inactive. Please contact support.',
                User::BANNED => 'Your account has been banned. Access denied.',
                default => 'Account status invalid.',
            });
        }

        $user->tokens()->delete();
        $plainTextToken = $user->createToken('api')->plainTextToken;

        $user->setHidden(['password', 'remember_token']);
        $user->token = $plainTextToken;

        return $this->apiResponse(true, 'Login successful', $user);
    }

    public function changePassword(ChangePasswordRequest $request): JsonResponse
    {
        $user = $request->user();
        $user->password = Hash::make($request->input('password'));
        $user->save();

        return $this->apiResponse(true, 'Password changed successfully');
    }

    public function logout(Request $request): JsonResponse
    {
        $request->currentAccessToken()->delete();
        return $this->apiResponse(true, 'Logout successful');
    }

    /**
     * Xác minh OTP email
     * POST: { email: string, code: string }
     * Thành công: set verified_at + GỬI MAIL CHÀO MỪNG ngay tại đây (đã move từ UserObserver).
     */
    public function verifyEmailOtp(Request $request): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'email' => 'required|email',
            'code' => 'required|string|min:6|max:6',
        ]);

        if ($v->fails()) {
            return $this->apiResponse(false, $v->errors()->first());
        }

        $user = User::where('email', $request->input('email'))->first();
        if (!$user) {
            return $this->apiResponse(false, 'User not found.');
        }

        if (!empty($user->email_verified_at)) {
            // Nếu đã verify trước đó, vẫn có thể gửi lại mail chào mừng nếu cần
            return $this->apiResponse(true, 'Email already verified.', [
                'verified' => true,
                'verified_at' => $user->email_verified_at,
            ]);
        }

        // Quá hạn?
        if (empty($user->email_verification_expires_at) || Carbon::now()->greaterThan($user->email_verification_expires_at)) {
            return $this->apiResponse(false, 'Verification code has expired. Please request a new one.');
        }

        // Quá số lần thử?
        if ($user->email_verification_attempts >= $this->maxVerifyAttempts) {
            return $this->apiResponse(false, 'Too many attempts. Please request a new code.');
        }

        // So khớp mã
        if (trim($request->input('code')) !== (string) $user->email_verification_code) {
            $user->increment('email_verification_attempts');
            return $this->apiResponse(false, 'Invalid code. Please try again.');
        }

        // Thành công: set verified + clear OTP fields
        $user->email_verified_at = Carbon::now();
        $user->email_verification_code = null;
        $user->email_verification_expires_at = null;
        $user->email_verification_attempts = 0;
        $user->save();

        try {
            try {
                $mailable = new UserRegisteredMail($user);
                $mailable->build();
                $subject = $mailable->subject ?? 'Account registration successful';
                $html = $mailable->render();

                app(GmailService::class)->sendMail($user->email, $subject, $html);
                dispatch(new SendWelcomeEmailJob($user->email, $subject, $html));
            } catch (Throwable $e) {
                logger()->error('Failed to send registration-completed email: ' . $e->getMessage());
            }
        } catch (Throwable $e) {
            logger()->error('Failed to send registration-completed email after verify: ' . $e->getMessage());
        }

        return $this->apiResponse(true, 'Email verified successfully.', [
            'verified' => true,
            'verified_at' => $user->email_verified_at,
        ]);
    }

    /**
     * Gửi lại OTP xác minh email
     */
    public function resendEmailOtp(Request $request): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'email' => 'required|email',
        ]);

        if ($v->fails()) {
            return $this->apiResponse(false, $v->errors()->first());
        }

        /** @var User|null $user */
        $user = User::where('email', $request->input('email'))->first();
        if (!$user) {
            return $this->apiResponse(false, 'User not found.');
        }

        if (!empty($user->email_verified_at)) {
            return $this->apiResponse(true, 'Email already verified.');
        }

        $key = $this->resendCooldownKey($user->email);
        if (Cache::has($key)) {
            $remain = Cache::get($key);
            return $this->apiResponse(false, "Please wait {$remain}s before requesting a new code.");
        }

        $otp = $this->generateOtp();
        $user->email_verification_code = $otp;
        $user->email_verification_expires_at = Carbon::now()->addMinutes($this->otpTtlMinutes);
        $user->email_verification_attempts = 0;
        $user->save();

        $this->seedResendCooldown($user->email);

        try {
            $mailable = new VerifyEmailOtpMail($user, $otp, $this->otpTtlMinutes);
            $mailable->build();
            $subject = $mailable->subject ?? 'Verify your email';
            $html = $mailable->render();

            dispatch(new SendVerifyEmailOtpJob($user->email, $subject, $html));
        } catch (Throwable $e) {
            logger()->error('Failed to resend verify email OTP via Gmail API: ' . $e->getMessage());
            return $this->apiResponse(false, 'Failed to send verification code. Please try again later.');
        }

        return $this->apiResponse(true, 'A new verification code has been sent to your email.', [
            'otp_ttl_minutes' => $this->otpTtlMinutes,
        ]);
    }

    /* ====================== Password Reset ====================== */
    public function forgotPassword(Request $request): JsonResponse
    {
        $request->validate(['email' => 'required|email']);

        $user = User::where('email', $request->input('email'))->first();

        if ($user) {
            $token = Password::createToken($user);
            $ttl = (int) config('auth.passwords.' . config('auth.defaults.passwords') . '.expire', 60);

            $resetUrl = rtrim((string) config('app.frontend_url'), '/')
                . '/auth/user/reset-password?token=' . urlencode($token)
                . '&email=' . urlencode($user->email);

            try {
                $mailable = new ForgotPasswordMail($user, $token, $resetUrl, $ttl);
                $mailable->build();

                $subject = $mailable->subject ?? 'Password reset request';
                $html = $mailable->render();

                dispatch(new SendPasswordResetEmailJob($user->email, $subject, $html));
            } catch (Throwable $e) {
                logger()->error('Failed to dispatch password reset email job: ' . $e->getMessage());
            }
        }

        return $this->apiResponse(true, 'Password reset link sent to your email.');
    }

    public function resetPassword(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'token' => 'required|string',
            'password' => 'required|string|min:6|confirmed',
        ]);

        $payload = [
            'email' => strtolower(trim($request->input('email'))),
            'password' => $request->input('password'),
            'password_confirmation' => $request->input('password_confirmation'),
            'token' => $request->input('token'),
        ];

        $broker = Password::broker(config('auth.defaults.passwords', 'users'));

        $status = $broker->reset($payload, function ($user, $password) {
            $user->forceFill(['password' => Hash::make($password)])->save();
            $user->tokens()->delete();
        });

        return match ($status) {
            Password::PASSWORD_RESET => $this->apiResponse(true, 'Password reset successful.'),
            Password::INVALID_TOKEN => $this->apiResponse(false, 'Invalid or expired reset token. Please request a new one.'),
            Password::INVALID_USER => $this->apiResponse(false, 'Email not found.'),
            Password::RESET_THROTTLED => $this->apiResponse(false, 'Too many attempts. Please try again later.'),
            default => (function () use ($status) {
                    logger()->warning('[PasswordReset] Unknown broker status', ['status' => $status]);
                    return $this->apiResponse(false, 'Password reset failed.');
                })(),
        };
    }

    /* ====================== Helpers ====================== */
    protected function generateOtp(): string
    {
        return str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
    }

    protected function resendCooldownKey(string $email): string
    {
        return 'otp_resend_cooldown:' . sha1(strtolower($email));
    }

    protected function seedResendCooldown(string $email): void
    {
        $key = $this->resendCooldownKey($email);
        Cache::put($key, $this->resendCooldownSeconds, $this->resendCooldownSeconds);
    }
}
