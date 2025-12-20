<?php

namespace Modules\User\Http\Controllers;

use Throwable;
use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Support\Carbon;
use Laravel\Socialite\Facades\Socialite;

use App\Models\User;
use App\Models\SocialAccount;

class SocialAuthController extends \App\Http\Controllers\Controller
{
    protected array $providers = ['google'];

    /** Lấy URL SPA callback (ưu tiên query spa_redirect, fallback env/config) */
    protected function spaRedirectUrl(Request $request): string
    {
        return (string) ($request->query('spa_redirect')
            ?? config('app.frontend_url')
            ?? env('FRONTEND_URL', '/'));
    }

    /** Redirect sang provider (stateless), nhúng state chứa spa_redirect */
    public function redirectToProvider(Request $request, string $provider): RedirectResponse
    {
        if (!in_array($provider, $this->providers, true)) {
            abort(404, 'Unsupported provider.');
        }

        $state = base64_encode(json_encode([
            'spa_redirect' => $this->spaRedirectUrl($request),
            'nonce'        => Str::random(16),
            'ts'           => time(),
        ]));

        /** @var \Laravel\Socialite\Two\GoogleProvider  */
        $driver = Socialite::driver($provider);

        return $driver->stateless()
            ->with(['state' => $state, 'prompt' => 'select_account'])
            ->redirectUrl(config("services.$provider.redirect"))
            ->redirect();
    }

    /** Callback từ provider -> phát token -> redirect về SPA */
    public function handleProviderCallback(Request $request, string $provider): RedirectResponse
    {
        if (!in_array($provider, $this->providers, true)) {
            abort(404, 'Unsupported provider.');
        }

        $stateRaw    = (string) $request->query('state', '');
        $state       = $this->parseState($stateRaw);
        $spaRedirect = $state['spa_redirect'] ?? $this->spaRedirectUrl($request);

        try {
            /** @var \Laravel\Socialite\Contracts\User $googleUser */
            $googleUser = Socialite::driver($provider)
                ->stateless()
                ->redirectUrl(config("services.$provider.redirect"))
                ->user();

            $providerId    = (string) ($googleUser->getId() ?? '');
            $providerEmail = (string) ($googleUser->getEmail() ?? '');
            $providerName  = (string) ($googleUser->getName() ?? $googleUser->getNickname() ?? '');
            $avatar        = (string) ($googleUser->getAvatar() ?? '');

            if ($providerId === '' || $providerEmail === '') {
                return $this->finishWithError($spaRedirect, 'Provider account missing id or email.');
            }

            [$user, $createdFresh] = DB::transaction(function () use (
                $provider,
                $providerId,
                $providerEmail,
                $providerName,
                $avatar
            ) {
                $social = SocialAccount::where([
                    'provider'    => $provider,
                    'provider_id' => $providerId,
                ])->first();

                if ($social) {
                    $user = $social->user;
                    $createdFresh = false;
                } else {
                    $user = User::where('email', $providerEmail)->first();

                    if (!$user) {
                        $user = User::create([
                            'name'              => $providerName ?: explode('@', $providerEmail)[0],
                            'email'             => $providerEmail,
                            'password'          => Hash::make(Str::random(40)),
                            'status'            => User::ACTIVE,
                            'is_staff'          => User::IS_USER,
                            'image'             => $avatar,
                            'email_verified_at' => Carbon::now(),
                            'description'       => "Registered via $provider",
                        ]);
                        $createdFresh = true;
                    } else {
                        $createdFresh = false;
                        if (empty($user->email_verified_at)) {
                            $user->email_verified_at = Carbon::now();
                        }
                        if (empty($user->image) && $avatar) {
                            $user->image = $avatar;
                        }
                        $user->save();
                    }

                    SocialAccount::updateOrCreate(
                        [
                            'provider'    => $provider,
                            'provider_id' => $providerId,
                        ],
                        [
                            'user_id'        => $user->id,
                            'provider_email' => $providerEmail,
                            'provider_name'  => $providerName,
                            'avatar'         => $avatar,
                        ]
                    );
                }

                return [$user, $createdFresh];
            });

            if ((string)$user->status !== User::ACTIVE) {
                $msg = match ((string)$user->status) {
                    User::PENDING  => 'Your registration is pending approval. Please wait for confirmation.',
                    User::INACTIVE => 'Your account is inactive. Please contact support.',
                    User::BANNED   => 'Your account has been banned. Access denied.',
                    default        => 'Account status invalid.',
                };
                return $this->finishWithError($spaRedirect, $msg);
            }

            $token = $user->createToken('auth_token')->plainTextToken;

            return $this->finishWithSuccess($spaRedirect, $token);
        } catch (Throwable $e) {
            return $this->finishWithError($spaRedirect, 'Authentication failed. Please try again.');
        }
    }

    protected function parseState(?string $raw): array
    {
        if (!$raw) return [];
        try {
            return (array) json_decode(base64_decode($raw), true, 512, JSON_THROW_ON_ERROR);
        } catch (Throwable) {
            return [];
        }
    }

    protected function finishWithSuccess(string $spaRedirect, string $token): RedirectResponse
    {
        // Redirect kiểu nhanh: token qua query. (Bạn có thể đổi sang postMessage/cookie nếu muốn ẩn URL)
        $url = rtrim($spaRedirect, '/') . '/api/common/social/callback?token=' . urlencode($token);
        return redirect()->to($url);
    }

    protected function finishWithError(string $spaRedirect, string $message): RedirectResponse
    {
        $url = rtrim($spaRedirect, '/') . '/api/common/social/callback?error=' . urlencode($message);
        return redirect()->to($url);
    }
}
