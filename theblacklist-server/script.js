const actions = document.getElementsByClassName("action");
const modal = document.getElementsByClassName("modal")[0];

function openModal(steamid) {
	modal.classList.add("fading-in");
	modal.style.display = "block";
	modal.children[0].children[2].children[1].value = steamid;
	modal.children[0].children[0].children[2].value = steamid;
	setTimeout(() => {
		modal.classList.remove("fading-in");
	}, 200);
}

for (let i=0; i < actions.length; i++) {
	actions[i].addEventListener("click", (e) => {
		openModal(e.target.getAttribute("steamid"));
	});
}