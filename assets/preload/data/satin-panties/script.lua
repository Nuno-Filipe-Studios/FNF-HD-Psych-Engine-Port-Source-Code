local allowCountdown = false
function onStartCountdown()
	if not allowCountdown and isStoryMode and not seenCutscene and dialogueIsStoryMode and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/week4_1', 0, 0);
		setObjectCamera('cutsceneImage','dialogue')
		addLuaSprite('cutsceneImage', true)

		makeLuaSprite('cutsceneImage2', 'dialogue/bg/week4_2', 0, 0);
		setObjectCamera('cutsceneImage2','dialogue')
		addLuaSprite('cutsceneImage2', true)

		setProperty('cutsceneImage.visible', true)
		setProperty('cutsceneImage2.visible', false)
		setProperty('inCutscene', true)
		startDialogue('dialogue', 'dialogue/mommiTalki', 0.9)

		allowCountdown = true
		return Function_Stop
	elseif not allowCountdown and not seenCutscene and dialogueIsEverywhere and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/week4_1', 0, 0);
		setObjectCamera('cutsceneImage','dialogue')
		addLuaSprite('cutsceneImage', true)

		makeLuaSprite('cutsceneImage2', 'dialogue/bg/week4_2', 0, 0)
		setObjectCamera('cutsceneImage2','dialogue')
		addLuaSprite('cutsceneImage2', true)

		setProperty('cutsceneImage.visible', true)
		setProperty('cutsceneImage2.visible', false)
		setProperty('inCutscene', true);
		startDialogue('dialogue', 'dialogue/mommiTalki', 0.9)

		allowCountdown = true
		return Function_Stop
	end
	doTweenAlpha('cutsceneImageTween', 'cutsceneImage', 0, 1.2, 'circout')
	doTweenAlpha('cutsceneImageTween2', 'cutsceneImage2', 0, 1.2, 'circout')
	runTimer('removeSprites', 1.2)
	return Function_Continue
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'removeSprites' then
		removeLuaSprite('cutsceneImage')
		removeLuaSprite('cutsceneImage2')
	end
end

function onNextDialogue(count)
	if count == 25 then
		removeLuaSprite('cutsceneImage')
		setProperty('cutsceneImage2.visible', true)
	end
end

function onSkipDialogue(count)
	
end