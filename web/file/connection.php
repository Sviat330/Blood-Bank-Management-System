<?php
$servername ="localhost";
$username ="bloodbank";
$password = "wasd74";
$dbname = "bloodbank";
$conn = new mysqli($servername, $username, $password, $dbname);
if(!$conn){
 die('Could not Connect MySql:' .mysql_error());
}
?>