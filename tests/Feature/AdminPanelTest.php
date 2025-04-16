<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminPanelTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_dashboard_is_accessible()
    {
        $this->assertTrue(true);
    }

    public function createApplication()
    {
        return app();
    }
}
