<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\EventController;
use App\Http\Controllers\ExpenseController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/forgot-password', [AuthController::class, 'sendOtp']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);
Route::post('/auth/google', [AuthController::class, 'googleLogin']);

// Protected routes (Requires token)
Route::middleware('auth:api')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/home/dashboard', [DashboardController::class, 'home']);
    Route::get('/dashboard', [DashboardController::class, 'home']);

    Route::get('/events', [EventController::class, 'index']);
    Route::post('/events', [EventController::class, 'store']);
    Route::get('/events/{event}', [EventController::class, 'show']);
    Route::post('/expenses/create', [ExpenseController::class, 'create']);
    Route::post('/expenses/{expense}/update', [ExpenseController::class, 'update']);
    Route::post('/expenses/{expense}/delete', [ExpenseController::class, 'destroy']);
    Route::get('/expenses', [ExpenseController::class, 'index']);
    Route::get('/expenses/{expense}', [ExpenseController::class, 'show']);
    Route::get('/categories', [ExpenseController::class, 'categories']);
    Route::post('/categories', [ExpenseController::class, 'storeCategory']);
    Route::put('/categories/{category}', [ExpenseController::class, 'updateCategory']);
    Route::delete('/categories/{category}', [ExpenseController::class, 'deleteCategory']);

    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::post('/events/join', [EventController::class, 'join']);
    Route::post('/events/join/claim', [EventController::class, 'claim']);
    Route::get('/events/{event}/invite', [EventController::class, 'invite']);

    Route::put('/events/{event}', [EventController::class, 'update']);
    Route::delete('/events/{event}', [EventController::class, 'destroy']);
});
