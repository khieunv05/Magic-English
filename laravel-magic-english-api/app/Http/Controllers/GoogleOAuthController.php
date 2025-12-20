<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Storage;
use Google_Client;
use Google_Service_Gmail;

class GoogleOAuthController extends Controller
{
    protected function getClient()
    {
        $client = new Google_Client();

        // Lấy từ bảng settings (cache)
        $client->setAuthConfig(storage_path('app/private/google/client_secret.json'));
        $client->setClientId(get_setting_from_cache('google_client_id'));
        $client->setClientSecret(get_setting_from_cache('google_client_secret'));
        $client->setRedirectUri(get_setting_from_cache('google_gmail_redirect_uri'));

        $client->addScope(Google_Service_Gmail::GMAIL_SEND);
        $client->setAccessType('offline');
        $client->setPrompt('consent');

        return $client;
    }

    public function redirect()
    {
        $client  = $this->getClient();
        $authUrl = $client->createAuthUrl();
        return redirect($authUrl);
    }

    public function callback()
    {
        $client = $this->getClient();
        $code   = request('code');

        if (!$code) {
            return response()->json(['error' => 'Missing code'], 400);
        }

        $token = $client->fetchAccessTokenWithAuthCode($code);
        Storage::disk('local')->put('google/token.json', json_encode($token));

        return response()->json(['message' => 'Token saved successfully']);
    }
}
