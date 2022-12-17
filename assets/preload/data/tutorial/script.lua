local allowCountdown = false
function onStartCountdown()
	if not allowCountdown and not seenCutscene and isStoryMode and dialogueIsStoryMode and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/tutorialcutscene', 0, 0)
		setObjectCamera('cutsceneImage','dialogue')
		addLuaSprite('cutsceneImage', true)

		setProperty('inCutscene', true)
		startDialogue('dialogue')

		allowCountdown = true
		return Function_Stop
	elseif not allowCountdown and not seenCutscene and dialogueIsEverywhere and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/tutorialcutscene', 0, 0)
		setObjectCamera('cutsceneImage','dialogue')
		addLuaSprite('cutsceneImage', true)

		setProperty('inCutscene', true)
		startDialogue('dialogue')

		allowCountdown = true
		return Function_Stop
	end
	doTweenAlpha('cutsceneImageTween', 'cutsceneImage', 0, 1.2, 'circout')
	runTimer('removeSprites', 1.2)
	return Function_Continue
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'removeSprites' then
		removeLuaSprite('cutsceneImage')
	end
end

function onNextDialogue(count)

end

function onSkipDialogue(count)
	
end