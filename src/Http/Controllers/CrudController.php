<?php

namespace ZenNavi\LaravelAdmin\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

class CrudController extends Controller
{
    public function index()
    {
        return view('laravel-admin::crud.index');
    }

    public function create()
    {
        return view('laravel-admin::crud.create');
    }
}
