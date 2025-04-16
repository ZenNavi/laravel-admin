<?php

namespace ZenNavi\LaravelAdmin\Console\Commands;

use Illuminate\Console\Command;

class MakeCrudCommand extends Command
{
    protected $signature = 'admin:make-crud {name}';
    protected $description = 'Create a new CRUD for Laravel Admin';

    public function handle()
    {
        $name = $this->argument('name');
        $this->info("Creating CRUD for {$name}...");
    }
}
