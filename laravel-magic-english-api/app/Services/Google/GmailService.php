<?php

namespace App\Services\Google;

use Exception;
use Google\Client;
use Google\Service\Gmail;
use Google\Service\Gmail\Message;

class GmailService
{
    protected Client $client;

    public function __construct()
    {
        $this->client = new Client();

        $this->client->setClientId(get_setting_from_cache('google_client_id'));
        $this->client->setClientSecret(get_setting_from_cache('google_client_secret'));
        $this->client->setRedirectUri(get_setting_from_cache('google_redirect_uri'));

        $this->client->addScope(Gmail::GMAIL_SEND);
        $this->client->setAccessType('offline');

        $tokenPath = storage_path('app/private/google/token.json');

        if (file_exists($tokenPath)) {
            $accessToken = json_decode(file_get_contents($tokenPath), true);
            $this->client->setAccessToken($accessToken);

            if ($this->client->isAccessTokenExpired() && $this->client->getRefreshToken()) {
                $this->client->fetchAccessTokenWithRefreshToken($this->client->getRefreshToken());
                file_put_contents($tokenPath, json_encode($this->client->getAccessToken()));
            }
        } else {
            throw new Exception('Token file not found. Please authorize first.');
        }
    }

    /**
     * Gửi email qua Gmail API
     */
    public function sendMail(string $to, string $subject, string $body)
    {
        $service = new Gmail($this->client);

        $rawMessage  = "From: me\r\n";
        $rawMessage .= "To: {$to}\r\n";
        $rawMessage .= "Subject: {$subject}\r\n";
        $rawMessage .= "MIME-Version: 1.0\r\n";
        $rawMessage .= "Content-Type: text/html; charset=utf-8\r\n\r\n";
        $rawMessage .= $body;

        // Chuẩn hóa MIME -> Base64URL
        $mime = rtrim(strtr(base64_encode($rawMessage), '+/', '-_'), '=');

        $message = new Message();
        $message->setRaw($mime);

        // Gửi thư
        return $service->users_messages->send('me', $message);
    }
}
