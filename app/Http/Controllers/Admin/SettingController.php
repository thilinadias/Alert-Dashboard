<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class SettingController extends Controller
{
    public function index()
    {
        $settings = Setting::all()->pluck('value', 'key');
        return view('admin.settings.index', compact('settings'));
    }

    public function update(Request $request)
    {
        $request->validate([
            'system_name' => 'nullable|string|max:255',
            'copyright_text' => 'nullable|string|max:255',
            'logo' => 'nullable|image|mimes:jpeg,png,jpg,svg|max:2048',
            'google_client_id' => 'nullable|string',
            'google_client_secret' => 'nullable|string',
            'microsoft_client_id' => 'nullable|string',
            'microsoft_client_secret' => 'nullable|string',
        ]);

        if ($request->has('system_name')) {
            Setting::set('system_name', $request->system_name);
        }

        if ($request->has('copyright_text')) {
            Setting::set('copyright_text', $request->copyright_text);
        }
        
        // OAuth Settings
        $oauthFields = [
            'google_client_id', 'google_client_secret', 'google_redirect_uri',
            'microsoft_client_id', 'microsoft_client_secret', 'microsoft_tenant_id', 'microsoft_redirect_uri'
        ];

        foreach ($oauthFields as $field) {
            if ($request->has($field)) {
                Setting::set($field, $request->input($field));
            }
        }

        if ($request->hasFile('logo')) {
            // Delete old logo if exists?
            // $oldLogo = Setting::get('logo_path');
            // if ($oldLogo) Storage::disk('public')->delete($oldLogo);

            $path = $request->file('logo')->store('branding', 'public');
            Setting::set('logo_path', $path);
        }

        return back()->with('success', 'Settings updated successfully.');
    }
}
