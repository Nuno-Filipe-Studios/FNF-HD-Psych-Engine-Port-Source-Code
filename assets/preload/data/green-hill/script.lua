local allowCountdown = false
function onStartCountdown()
	if not allowCountdown and isStoryMode and not seenCutscene and dialogueIsStoryMode and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/green_hill_1', 0, 0)
		setObjectCamera('cutsceneImage', 'dialogue')
		addLuaSprite('cutsceneImage', true)

		makeLuaSprite('cutsceneImage2', 'dialogue/bg/green_hill_2', 0, 0)
		setObjectCamera('cutsceneImage2', 'dialogue')
		addLuaSprite('cutsceneImage2', true)

		makeLuaSprite('blackBG', 'colors/black', 0, 0)
		setObjectCamera('blackBG', 'dialogue')
		addLuaSprite('blackBG', true)

		makeLuaSprite('bgFade', 'colors/weirdwhite', 0, 0)
		setObjectCamera('bgFade', 'dialogue')
		addLuaSprite('bgFade', true)

		setProperty('cutsceneImage.visible', false)
		setProperty('cutsceneImage2.visible', false)
		setProperty('bgFade.alpha', 0)
		setProperty('inCutscene', true)
		startDialogue('dialogue')
		doTweenAlpha('bgFadeTween', 'bgFade', 0.7, 1, 'circout')

		allowCountdown = true
		return Function_Stop
	elseif not allowCountdown and not seenCutscene and dialogueIsEverywhere and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/green_hill_1', 0, 0)
		setObjectCamera('cutsceneImage', 'dialogue')
		addLuaSprite('cutsceneImage', true)

		makeLuaSprite('cutsceneImage2', 'dialogue/bg/green_hill_2', 0, 0)
		setObjectCamera('cutsceneImage2', 'dialogue')
		addLuaSprite('cutsceneImage2', true)

		makeLuaSprite('blackBG', 'colors/black', 0, 0)
		setObjectCamera('blackBG', 'dialogue')
		addLuaSprite('blackBG', true)

		makeLuaSprite('bgFade', 'colors/weirdwhite', 0, 0)
		setObjectCamera('bgFade', 'dialogue')
		addLuaSprite('bgFade', true)

		setProperty('cutsceneImage.visible', false)
		setProperty('cutsceneImage2.visible', false)
		setProperty('bgFade.alpha', 0)
		setProperty('inCutscene', true)
		startDialogue('dialogue')
		doTweenAlpha('bgFadeTween', 'bgFade', 0.7, 1, 'circout')

		allowCountdown = true
		return Function_Stop
	end
	doTweenAlpha('cutsceneImageTween', 'cutsceneImage', 0, 1.2, 'circout')
	doTweenAlpha('cutsceneImageTween2', 'cutsceneImage2', 0, 1.2, 'circout')
	doTweenAlpha('blackBGTween', 'blackBG', 0, 1.2, 'circout')
	doTweenAlpha('bgFadeTween2', 'bgFade', 0, 1.2, 'circout')
	runTimer('removeSprites', 1.2)
	return Function_Continue
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'removeSprites' then
		removeLuaSprite('cutsceneImage')
		removeLuaSprite('cutsceneImage2')
		removeLuaSprite('blackBG')
		removeLuaSprite('bgFade')
	end
end

function onNextDialogue(count)
	if count == 2 then
		removeLuaSprite('blackBG')
		removeLuaSprite('bgFade')
		setProperty('cutsceneImage.visible', true)
	elseif count == 7 then
		removeLuaSprite('cutsceneImage')
		setProperty('cutsceneImage2.visible', true)
	end
end

function onSkipDialogue(count)
	
end