<?php

	set_include_path($_SERVER['DOCUMENT_ROOT']  . "/" . "modules");
	
	// Require modules
	require_once( 'Constants.class.php');

	$username = $_POST['username'];
	$score = $_POST['score'];

	$connect = mysqli_connect(Constants::DB_HOST, Constants::DB_USER, Constants::DB_PASSWORD);
	mysqli_select_db($connect,"hallaby_pony");

	$username = mysqli_real_escape_string($connect,$username);

	if($username) {
		$insert = "INSERT INTO high_scores(username,score,score_date) VALUES ('$username',$score,NOW())";
		$insertquery = mysqli_query($connect,$insert);
	}

	mysqli_close($connect);
?>