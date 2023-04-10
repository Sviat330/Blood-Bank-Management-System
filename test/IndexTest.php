<?php

// Load the file we want to test
require 'index.php';

class IndexTest extends \PHPUnit\Framework\TestCase
{
    public function testSessionStarted()
    {
        $this->assertTrue(isset($_SESSION));
    }
}
