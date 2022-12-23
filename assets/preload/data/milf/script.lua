local allowCountdown = false
function onStartCountdown()
	if not allowCountdown and isStoryMode and not seenCutscene and dialogueIsStoryMode and dialogueIsDisabled then
		if not oldHDsprites then
			makeLuaSprite('cutsceneImage', 'dialogue/bg/news2', 0, 0);
			setObjectCamera('cutsceneImage','dialogue')
			addLuaSprite('cutsceneImage', true)

			makeLuaSprite('cutsceneImage2', 'dialogue/bg/news3', 0, 0);
			setObjectCamera('cutsceneImage2','dialogue')
			addLuaSprite('cutsceneImage2', true)
		else
			makeLuaSprite('cutsceneImage', 'dialogue/bg/news2-old', 0, 0);
			setObjectCamera('cutsceneImage','dialogue')
			addLuaSprite('cutsceneImage', true)

			makeLuaSprite('cutsceneImage2', 'dialogue/bg/news3-old', 0, 0);
			setObjectCamera('cutsceneImage2','dialogue')
			addLuaSprite('cutsceneImage2', true)
		end

		makeLuaSprite('blackBG', 'colors/black', 0, 0)
		setObjectCamera('blackBG','dialogue')
		addLuaSprite('blackBG', true)

		makeLuaSprite('bgFade', 'colors/weirdwhite', 0, 0)
		setObjectCamera('bgFade','dialogue')
		addLuaSprite('bgFade', true)

		setProperty('bgFade.alpha', 0.7)
		setProperty('cutsceneImage.visible', true)
		setProperty('cutsceneImage2.visible', false)
		setProperty('blackBG.visible', false)
		setProperty('bgFade.visible', false)
		setProperty('inCutscene', true)
		startDialogue('dialogue')
		playSound('dialogue/news/10', 1, 'news10')

		allowCountdown = true
		return Function_Stop
	elseif not allowCountdown and not seenCutscene and dialogueIsEverywhere and dialogueIsDisabled then
		if not oldHDsprites then
			makeLuaSprite('cutsceneImage', 'dialogue/bg/news2', 0, 0);
			setObjectCamera('cutsceneImage','dialogue')
			addLuaSprite('cutsceneImage', true)

			makeLuaSprite('cutsceneImage2', 'dialogue/bg/news3', 0, 0);
			setObjectCamera('cutsceneImage2','dialogue')
			addLuaSprite('cutsceneImage2', true)
		else
			makeLuaSprite('cutsceneImage', 'dialogue/bg/news2-old', 0, 0);
			setObjectCamera('cutsceneImage','dialogue')
			addLuaSprite('cutsceneImage', true)

			makeLuaSprite('cutsceneImage2', 'dialogue/bg/news3-old', 0, 0);
			setObjectCamera('cutsceneImage2','dialogue')
			addLuaSprite('cutsceneImage2', true)
		end

		makeLuaSprite('blackBG', 'colors/black', 0, 0)
		setObjectCamera('blackBG','dialogue')
		addLuaSprite('blackBG', true)

		makeLuaSprite('bgFade', 'colors/weirdwhite', 0, 0)
		setObjectCamera('bgFade','dialogue')
		addLuaSprite('bgFade', true)

		setProperty('bgFade.alpha', 0.7)
		setProperty('cutsceneImage.visible', true)
		setProperty('cutsceneImage2.visible', false)
		setProperty('blackBG.visible', false)
		setProperty('bgFade.visible', false)
		setProperty('inCutscene', true)
		startDialogue('dialogue')
		playSound('dialogue/news/10', 1, 'news10')

		allowCountdown = true;
		return Function_Stop;
	end
	doTweenAlpha('cutsceneImageTween', 'cutsceneImage', 0, 1.2, 'circout')
	doTweenAlpha('cutsceneImageTween2', 'cutsceneImage2', 0, 1.2, 'circout')
	doTweenAlpha('blackBGTween', 'blackBG', 0, 1.2, 'circout')
	doTweenAlpha('bgFadeTween', 'bgFade', 0, 1.2, 'circout')
	soundFadeOut('news10', 1, 0)
	soundFadeOut('news11', 1, 0)
	soundFadeOut('news12', 1, 0)
	runTimer('removeSprites', 1.2)
	runTimer('removeSounds', 1)
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'removeSprites' then
		removeLuaSprite('cutsceneImage', true)
		removeLuaSprite('cutsceneImage2', true)
		removeLuaSprite('blackBG', true)
	end
	if tag == 'removeSounds' then
		stopSound('news10')
		stopSound('news11')
		stopSound('news12')
	end
	if tag == 'startEndDialogue' then
		doTweenAlpha('bgFadeTween2', 'bgFade', 0.7, 1, 'circout')
		if badEnding then
			print('bad ending :(')
			startDialogue('dialogueBadEnd')
		else
			print('good ending :)')
			startDialogue('dialogueGoodEnd')
		end
	end
	if tag == 'removeSprites2' then
		removeLuaSprite('bgFade')
	end
	if tag == 'startCutscene' then
		print('bad ending cutscene started')
		makeLuaSprite('blackBG', 'colors/black', -500, -160)
		setScrollFactor('blackBG', 0, 0)
		scaleObject('blackBG', 50, 50)
		addLuaSprite('blackBG', false)

		makeLuaSprite('blackBG2', 'colors/black', 0, 0)
		setObjectCamera('blackBG2','dialogue')
		addLuaSprite('blackBG2', true)
		setProperty('blackBG2.alpha', 0)

		playAnim('dad', 'shootThatMF')
		setProperty('dad.specialAnim', true)
		if screenShakes then
			cameraShake('game', 0.01, 0.2)
		end
		playSound('bwow')
		startBeam()

		triggerEvent('Change Character', 'bf', 'bf-laser-dead')
		playAnim('boyfriend', 'firstDeath')
		playAnim('gf', 'sad-cutscene')
		setProperty('boyfriend.specialAnim', true)
		setProperty('gf.specialAnim', true)
		setProperty('overlay.visible', false)

		playSound('fnf_loss_sfx')
		runTimer('startNextCutscene', 3)
	end
	if tag == 'startFade' then
		print('screen fade started')
		doTweenAlpha('blackBGTween5', 'blackBG2', 1, 4, 'circout')
		runTimer('finish', 6)
		musicFadeOut(4, 0)
	end
	if tag == 'startNextCutscene' then
		print('bf death anim started')
		playAnim('boyfriend', 'deathLoop')
		setProperty('boyfriend.specialAnim', true)

		playMusic('gameOver', 1, true)
		runTimer('startFade', 2)
	end
	if tag == 'finish' then
		print('cutscene finished!')
		setProperty('inCutscene', false)
		fuckingEnded = true
		exitSong()
	end
end

function onNextDialogue(count)
	if count == 1 then
		removeLuaSprite('cutsceneImage', true)
		setProperty('cutsceneImage2.visible', true)
		stopSound('news10')
		playSound('dialogue/news/11', 1, 'news11')
	elseif count == 2 then
		setProperty('cutsceneImage2.visible', true)
		stopSound('news11')
		playSound('dialogue/news/12', 1, 'news12')
	elseif count == 3 then
		removeLuaSprite('cutsceneImage2', true)
		setProperty('blackBG.visible', true)
		setProperty('bgFade.visible', true)
		stopSound('news12')
		playMusic('dialogue/mommiTalki', 0.9, true)
	end
end

function onSkipDialogue(count)
	
end

local allowEndShit = false
local seenShit = false
local fuckingEnded = false
function onEndSong()
	if not allowEndShit and isStoryMode and dialogueIsStoryMode and dialogueIsDisabled then
		makeLuaSprite('blackBG', 'colors/black', 0, 0)
		setObjectCamera('blackBG','dialogue')
		addLuaSprite('blackBG', true)

		makeLuaSprite('bgFade', 'colors/weirdwhite', 0, 0)
		setObjectCamera('bgFade','dialogue')
		addLuaSprite('bgFade', true)

		setProperty('blackBG.alpha', 0)
		setProperty('bgFade.alpha', 0)
		setProperty('inCutscene', true)
		doTweenAlpha('blackBGTween2', 'blackBG', 1, 0.5, 'circout')
		runTimer('startEndDialogue', 0.5)

		allowEndShit = true
		return Function_Stop
	elseif not allowEndShit and dialogueIsEverywhere and dialogueIsDisabled then
		makeLuaSprite('blackBG', 'colors/black', 0, 0)
		setObjectCamera('blackBG','dialogue')
		addLuaSprite('blackBG', true)

		makeLuaSprite('bgFade', 'colors/weirdwhite', 0, 0)
		setObjectCamera('bgFade','dialogue')
		addLuaSprite('bgFade', true)

		setProperty('blackBG.alpha', 0)
		setProperty('bgFade.alpha', 0)
		setProperty('inCutscene', true)
		doTweenAlpha('blackBGTween2', 'blackBG', 1, 0.5, 'circout')
		runTimer('startEndDialogue', 0.5)

		allowEndShit = true
		seenShit = true
		return Function_Stop
	end
	if badEnding and seenShit and not fuckingEnded then
		triggerEvent('Change Character', 'dad', 'mom-car')
		triggerEvent('Camera Follow Pos', '960', '340')
		setProperty('camHUD.visible', false)
		doTweenAlpha('blackBGTween3', 'blackBG', 0, 1.2, 'circout')
		doTweenAlpha('bgFadeTween4', 'bgFade', 0, 1.2, 'circout')
		runTimer('removeSprites2', 1.2)
		runTimer('startCutscene', 1.4)
		return Function_Stop
	end
	if not badEnding then
		doTweenAlpha('bgFadeTween4', 'bgFade', 0, 1.2, 'circout')
		runTimer('removeSprites2', 1.2)
	end
	return Function_Continue
end

function onNextEndDialogue(count)
	
end

function onSkipEndDialogue(count)

end

function onUpdatePost()

end