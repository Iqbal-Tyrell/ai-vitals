<?php

test('health check route returns ok status', function () {
    $response = $this->get('/up');

    $response->assertStatus(200)
        ->assertExactJson(['status' => 'ok']);
});
