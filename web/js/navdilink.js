// general purpose API for usage by navdi

const navdilink = {
			globalAudioCtx : new (window.AudioContext || window.webkitAudioContext)({ latencyHint: "balanced" });
			onDrop(files){
				console.log("navdilink default onDrop has not been overridden yet")
			},
			setDropCallback(cb){
				console.log("navdilink setDropCallback disabled; Godot web builds handle it fine themselves")
				// this.onDrop=cb;
			},

			bgm_synth : null,
			play_bgm_string(bgm_string){
				console.log("play",bgm_string);
				this.stop_bgm();
				this.bgm_synth = new beepbox.Synth(bgm_string, this.globalAudioCtx);
				this.bgm_synth.play();
			},

			// TODO: rather than 'cutting off' the synth,
			// devise code for stopping all playback but
			// allow synth to continue playing.

			stop_bgm(){
				if(this.bgm_synth!=null) {
					this.bgm_synth.pause();
					this.bgm_synth = null;
				}
			},

			play_sfx_string(sfx_string){
				let sfx_synth = new beepbox.Synth(sfx_string, this.globalAudioCtx);
				sfx_synth.loopRepeatCount = 0; // no looping!
				sfx_synth.play();
				this._track_sfx(sfx_synth);
			},

			sfxs_playing : [],
			_track_sfx(sfx){
				if(sfx.loopRepeatCount<0) {
					throw new Error("navdilink should only track_sfx on a nonlooping beepbox synth");
				} else {
					this.sfxs_playing.push(sfx);
				}
			},
			_cleanup_sfxs(){
				this.sfxs_playing.filter(sfx => !sfx.ended);
			},
};

window.navdilink = navdilink;
