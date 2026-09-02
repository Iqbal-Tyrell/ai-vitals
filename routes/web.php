<?php

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/up', function () {
    return response()->json(['status' => 'ok']);
});

// Deliberately flawed test route for fix-loop verification
Route::get('/test-flaw2', function () {
    $userId = request()->query('id');
    $result = DB::select('SELECT id, name, email FROM users WHERE id = ?', [$userId]);

    return $result;
})->middleware('auth');
