<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class BackupDatabase extends Command
{
    protected $signature   = 'db:backup';
    protected $description = 'Create a compressed database backup';

    public function handle(): void
{
    $dbName   = config('database.connections.pgsql.database');
    $dbUser   = config('database.connections.pgsql.username');
    $dbPass   = config('database.connections.pgsql.password');
    $dbHost   = config('database.connections.pgsql.host');
    $backupDir = storage_path('backups');
    $filename  = 'tuaka-db-' . now()->format('Y-m-d-His') . '.sql.gz';
    $filepath  = $backupDir . '/' . $filename;

    if (! is_dir($backupDir)) {
        mkdir($backupDir, 0755, true);
    }

    // Set PGPASSWORD via putenv — works on both Windows and Linux
    putenv("PGPASSWORD={$dbPass}");

    $command = "pg_dump -U {$dbUser} -h {$dbHost} {$dbName}";

    // gzip is available on Linux; on Windows we skip compression locally
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        $filepath = str_replace('.sql.gz', '.sql', $filepath);
        exec("{$command} > \"{$filepath}\"", $output, $exitCode);
    } else {
        exec("{$command} | gzip > \"{$filepath}\"", $output, $exitCode);
    }

    putenv('PGPASSWORD='); // clear immediately after use

    if ($exitCode !== 0) {
        $this->error('Backup failed. Make sure pg_dump is in your PATH.');
        return;
    }

    $sizeMb = round(filesize($filepath) / 1024 / 1024, 2);
    $this->info("Backup created: " . basename($filepath) . " ({$sizeMb} MB)");

    // Clean up backups older than 30 days
    $files = array_merge(
        glob($backupDir . '/*.sql.gz') ?: [],
        glob($backupDir . '/*.sql') ?: [],
    );

    $cutoff  = now()->subDays(30)->timestamp;
    $deleted = 0;

    foreach ($files as $file) {
        if (filemtime($file) < $cutoff) {
            unlink($file);;
            $deleted++;
        }
    }

    if ($deleted > 0) {
        $this->info("Cleaned up {$deleted} old backup(s).");
    }
}
}