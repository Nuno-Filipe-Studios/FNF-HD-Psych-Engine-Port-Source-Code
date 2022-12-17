local allowCountdown = false
function onStartCountdown()
	if not allowCountdown and not seenCutscene and isStoryMode and dialogueIsStoryMode and dialogueIsDisabled then
		makeLuaSprite('blackBG', 'colors/black', 0, 0)
		setObjectCamera('blackBG','dialogue')
		addLuaSprite('blackBG', true)

		makeLuaSprite('bgFade', 'colors/weirdwhite', 0, 0)
		setObjectCamera('bgFade','dialogue')
		addLuaSprite('bgFade', true)

		setProperty('bgFade.alpha', 0)
		setProperty('inCutscene', true)
		startDialogue('dialogue')
		doTweenAlpha('bgFadeTween', 'bgFade', 0.7, 1, 'circout')

		allowCountdown = true
		return Function_Stop
	elseif not allowCountdown and not seenCutscene and dialogueIsEverywhere and dialogueIsDisabled then
		makeLuaSprite('blackBG', 'colors/black', 0, 0)
		setObjectCamera('blackBG','dialogue')
		addLuaSprite('blackBG', true)

		makeLuaSprite('bgFade', 'colors/weirdwhite', 0, 0)
		setObjectCamera('bgFade','dialogue')
		addLuaSprite('bgFade', true)

		setProperty('bgFade.alpha', 0)
		setProperty('inCutscene', true)
		startDialogue('dialogue')
		doTweenAlpha('bgFadeTween', 'bgFade', 0.7, 1, 'circout')

		allowCountdown = true
		return Function_Stop
	end
	doTweenAlpha('blackBGTween', 'blackBG', 0, 1.2, 'circout')
	doTweenAlpha('bgFadeTween2', 'bgFade', 0, 1.2, 'circout')
	runTimer('removeSprites', 1.2)
	return Function_Continue
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'removeSprites' then
		removeLuaSprite('blackBG')
		removeLuaSprite('bgFade')
	end
	if tag == 'startEndDialogue' then
		doTweenAlpha('bgFadeTween3', 'bgFade', 0.7, 1, 'circout')
		startDialogue('dialogueEnd')
	end
	if tag == 'removeSprites2' then
		removeLuaSprite('cutsceneImage')
		removeLuaSprite('cutsceneImage2')
		removeLuaSprite('cutsceneImage3')
		removeLuaSprite('blackBG')
		removeLuaSprite('bgFade')
	end
end

local allowEndShit = false
function onEndSong()
	if not allowEndShit and isStoryMode and dialogueIsStoryMode and dialogueIsDisabled then
		makeLuaSprite('blackBG', 'colors/black', 0, 0)
		setObjectCamera('blackBG', 'dialogue')
		addLuaSprite('blackBG', true)

		makeLuaSprite('bgFade', 'colors/weirdwhite', 0, 0)
		setObjectCamera('bgFade', 'dialogue')
		addLuaSprite('bgFade', true)

		makeLuaSprite('cutsceneImage', 'dialogue/bg/green_hill_3', 0, 0)
		setObjectCamera('cutsceneImage', 'dialogue')
		addLuaSprite('cutsceneImage', true)

		makeLuaSprite('cutsceneImage2', 'dialogue/bg/green_hill_4', 0, 0)
		setObjectCamera('cutsceneImage2', 'dialogue')
		addLuaSprite('cutsceneImage2', true)

		makeLuaSprite('cutsceneImage3', 'dialogue/bg/green_hill_5', 0, 0)
		setObjectCamera('cutsceneImage3', 'dialogue')
		addLuaSprite('cutsceneImage3', true)

		setProperty('cutsceneImage.visible', false)
		setProperty('cutsceneImage2.visible', false)
		setProperty('cutsceneImage3.visible', false)
		setProperty('blackBG.alpha', 0)
		setProperty('bgFade.alpha', 0)
		setProperty('inCutscene', true)
		doTweenAlpha('blackBGTween2', 'blackBG', 1, 0.5, 'circout')
		runTimer('startEndDialogue', 0.5)

		allowEndShit = true;
		return Function_Stop;
	elseif not allowEndShit and dialogueIsEverywhere and dialogueIsDisabled then
		makeLuaSprite('blackBG', 'colors/black', 0, 0)
		setObjectCamera('blackBG', 'dialogue')
		addLuaSprite('blackBG', true)

		makeLuaSprite('bgFade', 'colors/weirdwhite', 0, 0)
		setObjectCamera('bgFade', 'dialogue')
		addLuaSprite('bgFade', true)

		makeLuaSprite('cutsceneImage', 'dialogue/bg/green_hill_3', 0, 0)
		setObjectCamera('cutsceneImage', 'dialogue')
		addLuaSprite('cutsceneImage', true)

		makeLuaSprite('cutsceneImage2', 'dialogue/bg/green_hill_4', 0, 0)
		setObjectCamera('cutsceneImage2', 'dialogue')
		addLuaSprite('cutsceneImage2', true)

		makeLuaSprite('cutsceneImage3', 'dialogue/bg/green_hill_5', 0, 0)
		setObjectCamera('cutsceneImage3', 'dialogue')
		addLuaSprite('cutsceneImage3', true)

		setProperty('cutsceneImage.visible', false)
		setProperty('cutsceneImage2.visible', false)
		setProperty('cutsceneImage3.visible', false)
		setProperty('blackBG.alpha', 0)
		setProperty('bgFade.alpha', 0)
		setProperty('inCutscene', true)
		doTweenAlpha('blackBGTween2', 'blackBG', 1, 0.5, 'circout')
		runTimer('startEndDialogue', 0.5)

		allowEndShit = true;
		return Function_Stop;
	end
	doTweenAlpha('cutsceneImageTween', 'cutsceneImage', 0, 1.2, 'circout')
	doTweenAlpha('cutsceneImageTween2', 'cutsceneImage2', 0, 1.2, 'circout')
	doTweenAlpha('cutsceneImageTween3', 'cutsceneImage3', 0, 1.2, 'circout')
	doTweenAlpha('bgFadeTween4', 'bgFade', 0, 1.2, 'circout')
	runTimer('removeSprites2', 1.2)
	return Function_Continue;
end

function onNextEndDialogue(count)
	if count == 2 then
		setProperty('blackBG.visible', false)
		setProperty('bgFade.visible', false)
		setProperty('cutsceneImage.visible', true)
	elseif count == 12 then
		removeLuaSprite('cutsceneImage')
		setProperty('cutsceneImage2.visible', true)
	elseif count == 14 then
		setProperty('blackBG.visible', true)
		setProperty('bgFade.visible', true)
		removeLuaSprite('cutsceneImage2')
	elseif count == 25 then
		setProperty('blackBG.visible', true)
		removeLuaSprite('bgFade')
		setProperty('cutsceneImage3.visible', true)
	end
end

function onSkipEndDialogue(count)
	
end