<?php

$username = "changeme";
$password = "changeme2";

header("X-Frame-Options: DENY");

session_start();

if ( !(empty($_SESSION["login"]) || empty($_SESSION["password"])) ) {

	if ( $_SESSION["login"] === $username && $_SESSION["password"] === $password )
		$is_god = true;
	else {
		$error = '<div class="error">Please login again</div>';
		session_unset();
	}

} elseif ( !(empty($_POST["login"]) || empty($_POST["password"])) && is_string($_POST["login"]) && is_string($_POST["password"]) ) {
	if ( $_POST["login"] === $username && $_POST["password"] === $password ) {

		$_SESSION["login"] = $_POST["login"];
		$_SESSION["password"] = $_POST["password"];
		$is_god = true;

	} else {
		$error = '<div class="error">Invalid username or password</div>';
	}
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<link rel="stylesheet" href="style.css" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="robots" content="noindex">
	<meta name="description" content="Web panel to manage a Blacklist server">
	<meta name="author" content="Maks">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
	<title>Blacklist Servers Login</title>
</head>
<body>

<?php

// when it's login time

if (!isset($is_god)) { ?>
	<div class="login">
		<h1>Login</h1>
		<?= isset($error) ? $error : "" ?>
		<form method="POST">
			<input type="text" name="login" placeholder="Username"  required>
			<input type="password" name="password" placeholder="Password"  required>
			<input type="submit" value="Login">
		</form>
	</div>
</body>
</html>

<?php
	die();
}

// user authentified

if ( !empty($_POST["steamid"]) && !( is_string($_POST["steamid"]) && preg_match("/^STEAM_0:[01]:[0-9]{1,9}$/", $_POST["steamid"]) ) ) {
	unset($_POST["steamid"]);

	if (isset($_POST["add"]))
		$ret_add = '<div class="error">Invalid SteamID</div>';
	else
		$ret_del = '<div class="error">Invalid SteamID</div>';
}

function saveChange($banlist) {
	file_put_contents("banlist.json", json_encode($banlist));

	if (file_exists("version.txt"))
		$version = intval(file_get_contents("version.txt"));
	else
		$version = 0;

	file_put_contents("version.txt", $version + 1);
}

if (isset($_POST["add"]) && isset($_POST["steamid"]) || !empty($_POST["reason"]) && is_string($_POST["steamid"]) && is_string($_POST["reason"])) {

	if (file_exists("banlist.json")) {

		$banlist = json_decode(file_get_contents("banlist.json"), true);

		if (isset($banlist[ $_POST["steamid"] ]))
			$ret_add = '<div class="success">Reason modified</div>';
		else
			$ret_add = '<div class="success">SteamID added to banlist</div>';

		$banlist[ $_POST["steamid"] ] = $_POST["reason"];
		saveChange($banlist);

		if (file_exists("reportlist.php")) {
			include_once "reportlist.php";

			for ($i = count($report_list) - 1; $i >= 0; $i--)
				if ($report_list[$i]["victimSteam"] === $_POST["steamid"]) {
					$_POST["delete-report"] = true;
					break;
				}
		}
	} else {
		file_put_contents("banlist.json", array(
			$_POST["steamid"] => $_POST["reason"]
		));
	}
}

if (isset($_POST["delete"]) && isset($_POST["steamid"])) {
	
	if (file_exists("banlist.json")) {
		
		$banlist = json_decode(file_get_contents("banlist.json"), true);
		
		if (isset($banlist[ $_POST["steamid"] ])) {
			
			unset($banlist[ $_POST["steamid"] ]);
			saveChange($banlist);

			$ret_del = '<div class="success">SteamID removed from banlist</div>';
			
		} else {
			$ret_del = '<div class="error">SteamID not found</div>';
		}
	} else {
		$ret_del = '<div class="error">No banlist</div>';
	}
}

if (isset($_POST["delete-report"]) && isset($_POST["steamid"]) && file_exists("reportlist.php")) {

	include_once "reportlist.php";

	for ($i = count($report_list) - 1; $i >= 0; $i--)
		if ($report_list[$i]["victimSteam"] === $_POST["steamid"]) {
			
			array_splice($report_list, $i, 1);
			file_put_contents("reportlist.php", '<?php $report_list = json_decode(\'' . json_encode($report_list, JSON_HEX_APOS) . '\',true);');

			break;
		}
}

if (isset($_GET["report"])) {

	if (file_exists("reportlist.php"))
		include_once "reportlist.php";
	else
		$report_list = array();

	function steamid64($id) {
		$parts = explode(':', $id);
		return bcadd(bcadd(bcmul($parts[2], '2'), '76561197960265728'), $parts[1]);
	}

	?>

	<div class="panel">
		<h1>Report list</h1>
	<?php
		if (empty($report_list))
			echo '<h3 class="red">EMPTY</h3>';
		else {
			echo '<table><thead><tr><th>Reporter</th><th>Reported</th><th>Reason</th><th>Action</th></tr></thead><tbody>';

			for ($i = count($report_list) - 1; $i >= 0; $i--) { ?>
				<tr>
					<td>
						<a href="https://steamcommunity.com/profiles/<?= steamid64($report_list[$i]["senderSteam"]); ?>">Profile</a>
					</td>
					<td>
						<a href="https://steamcommunity.com/profiles/<?= steamid64($report_list[$i]["victimSteam"]); ?>">Profile</a>
					</td>
					<td>
						<?= htmlspecialchars($report_list[$i]["reason"]); ?>
					</td>
					<td>
						<button class="action" steamid="<?= $report_list[$i]["victimSteam"] ?>">Action</button>
					</td>
				</tr>
			<?php }

			echo '</tbody></table>';
		}
	?>
		<a class="switch" href="?">Dashboard</a>
	</div>

	<div class="modal">
		<div id="modal">
			<form method="POST">
				<h1 class="green">Add</h1>
				<input type="text" name="reason" placeholder="Reason">
				<input type="hidden" name="steamid" value="">
				<input type="submit" name="add" value="Add">
			</form>
			<hcut></hcut>
			<form method="POST">
				<h1 class="red">Remove</h1>
				<input type="hidden" name="steamid" value="">
				<input type="submit" name="delete-report" value="Remove">
			</form>
		</div>
	</div>
	<script src="script.js" async differ></script>
	
	<?php } else { ?>
		
	<div class="panel">
		<h1><span class="green">Add / Modify</span> SteamID</h1>
		<?= isset($ret_add) ? $ret_add : "" ?>
		<form method="POST">
			<input type="text" name="steamid" placeholder="SteamID" required>
			<input type="text" name="reason" placeholder="Reason" required>
			<input type="submit" name="add" value="Add">
		</form>
		
		<cut></cut>
		
		<h1><span class="red">Remove</span> SteamID</h1>
		<?= isset($ret_del) ? $ret_del : "" ?>
		<form method="POST">
			<input type="text" name="steamid" placeholder="SteamID" required>
			<input type="submit" name="delete" value="Remove">
		</form>
		<a class="switch" href="?report">Reports</a>
	</div>
		
<?php } ?>

</body>
</html>