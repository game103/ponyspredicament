<?php

	set_include_path($_SERVER['DOCUMENT_ROOT']  . "/" . "modules");
	
	// Require modules
	require_once( 'Constants.class.php');

	$username = $_POST['username'];
	$score = $_POST['score'];

	$connect = mysql_connect(Constants::DB_HOST, Constants::DB_USER, Constants::DB_PASSWORD);
	mysql_select_db("hallaby_pony");

	$username = mysql_real_escape_string($username);

	if($username) {
		$insert = "INSERT INTO high_scores(username,score,score_date) VALUES ('$username',$score,NOW())";
		$insertquery = mysql_query($insert, $connect);
	}

	mysql_close();
?>