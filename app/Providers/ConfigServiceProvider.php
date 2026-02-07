<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Models\Setting;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Config;

class ConfigServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        if (Schema::hasTable('settings')) {
            $this->loadOAuthSettings();
            $this->loadMailSettings();
        }
    }

    private function loadOAuthSettings()
    {
        // Google
        $googleId = Setting::get('google_client_id');
        $googleSecret = Setting::get('google_client_secret');
        $googleRedirect = Setting::get('google_redirect_uri');

        if ($googleId && $googleSecret) {
            Config::set('services.google.client_id', $googleId);
            Config::set('services.google.client_secret', $googleSecret);
            // Only set redirect if provided, otherwise fallback to .env or default
            if ($googleRedirect) {
                Config::set('services.google.redirect', $googleRedirect);
            }
        }

        // Microsoft
        $microsoftId = Setting::get('microsoft_client_id');
        $microsoftSecret = Setting::get('microsoft_client_secret');
        $microsoftTenant = Setting::get('microsoft_tenant_id');
        $microsoftRedirect = Setting::get('microsoft_redirect_uri');

        if ($microsoftId && $microsoftSecret) {
            Config::set('services.microsoft.client_id', $microsoftId);
            Config::set('services.microsoft.client_secret', $microsoftSecret);
            if ($microsoftTenant) {
                Config::set('services.microsoft.tenant_id', $microsoftTenant);
            }
            if ($microsoftRedirect) {
                Config::set('services.microsoft.redirect', $microsoftRedirect);
            }
        }
    }

    private function loadMailSettings()
    {
        // We can also load mail settings here if needed later
        // For now, sticking to OAuth as requested
    }
}
