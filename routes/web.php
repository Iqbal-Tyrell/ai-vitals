<?php

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
    $result = DB::select("SELECT * FROM users WHERE id = " . $userId);
    return $result;
});
