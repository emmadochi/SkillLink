use App\Http\Controllers\LoginController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\ArtisanManagementController;
use App\Http\Controllers\BookingManagementController;
use Illuminate\Support\Facades\Route;

// Auth Routes
Route::get('/', [LoginController::class, 'show'])->name('login');
Route::post('/login', [LoginController::class, 'login']);
Route::post('/logout', [LoginController::class, 'logout'])->name('logout');

// Admin Routes (Gated by auth)
Route::middleware(['auth'])->group(function () {
    Route::get('/admin', [DashboardController::class, 'index'])->name('admin.dashboard');
    Route::get('/admin/artisans', [ArtisanManagementController::class, 'index'])->name('admin.artisans');
    Route::get('/admin/bookings', [BookingManagementController::class, 'index'])->name('admin.bookings');
});
