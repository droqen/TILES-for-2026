function getRandomPastel() { // just for style purposes
	var letters = 'ABCDEF'; // '0123456789ABCDEF';
	var numletters = 6; // 16
	var color = '#';
	for (var i = 0; i < 6; i++) {
		color += letters[Math.floor(Math.random() * numletters)];
	}
	return color;
}

function hideProgress() {
	document.getElementById("progress-zone").style.display = "none";
}
let p = 0;
let nextPastel = 0;
function updateProgress(current, total) {
	console.log(`update ${current}/${total}`);
	if (current>0&&total>0){
		document.getElementById("progress-count").innerText = `LOADING ${(total/1000000.0).toFixed(1)}MB`
		let p2 = Math.ceil(current * 80 / total);
		if (p != p2) {
			p = p2;
			if (p >= nextPastel) {
				nextPastel += 10;
				let c = "#FFF";
				if (nextPastel < 70) {c = getRandomPastel();}
				document.getElementById("progress-bar").style.backgroundColor = c;
				document.getElementById("progress-count").style.color = c;
			}
			let pStr = `${p*1.25}%`;
			document.getElementById("progress-bar").style.height = pStr;
			console.log(document.getElementById("progress-bar"), document.getElementById("progress-bar").style.height,pStr);
		}
	} else{
		// uncertain what do
		document.getElementById("progress-count").innerText = `LOADING ??.?MB...`
	}
}
function displayFailureNotice() {
	document.getElementById("progress-count").innerText = `LOADING FAILED!`
}