<?php

function checkPOST($key) {
	return !empty($_POST[$key]) && is_string($key);
}

if ( !(checkPOST("senderSteam") && checkPOST("victimSteam") && checkPOST("reason")) )
	die("Invalid.");

function checkSTEAMID($steamid) {
	return preg_match("/^STEAM_0:[01]:[0-9]{1,9}$/", $steamid);
}

if ( !(checkSTEAMID($_POST["senderSteam"]) && checkSTEAMID($_POST["victimSteam"])) )
	die("Invalid.");

if (strlen($_POST["reason"]) >= 250)
	die("Max reason length is 250 characters");

if ( !(file_exists("reportlist.php") && (include "reportlist.php") && is_array($report_list)) )
	$report_list = array();

$count = 0;
for ($i = count($report_list) - 1; $i >= 0; $i--) {
	if ($report_list[$i]["victimSteam"] === $_POST["victimSteam"])
		if ($report_list[$i]["senderIP"] !== $_SERVER["REMOTE_ADDR"])
			die("Player already reported");
		else {
			$change = $i;
			break;
		}
	
	if ($report_list[$i]["senderIP"] === $_SERVER["REMOTE_ADDR"]) {
		$count++;

		if ($count >= 10) {
			die("Maximum report limit reached. Please wait");
		}
	}
}

$array = array(
	"senderSteam" => $_POST["senderSteam"],
	"victimSteam" => $_POST["victimSteam"],
	"reason" => $_POST["reason"],
	"senderIP" => $_SERVER["REMOTE_ADDR"]
);

if (isset($change) && is_int($change))
	$report_list[$change] = $array;
else
	array_push($report_list, $array);

file_put_contents("reportlist.php", '<?php $report_list = json_decode(\'' . json_encode($report_list, JSON_HEX_APOS) . '\',true);');