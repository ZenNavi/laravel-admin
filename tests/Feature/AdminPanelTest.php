<?php

namespace ZenNavi\LaravelAdmin\Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminPanelTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_dashboard_is_accessible()
    {
        $response = $this->get('/admin');
        $response->assertStatus(200);
    }
}
