<?php
$servername = getenv('DB_HOST');;
$username = getenv('DB_USER');
$password = getenv('DB_PASS');
$dbname = getenv('DB_NAMES');
$conn = new mysqli($servername, $username, $password, $dbname);
if(!$conn){
 die('Could not Connect MySql:' .mysql_error());
}
?>
