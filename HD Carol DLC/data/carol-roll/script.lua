local allowCountdown = false
function onStartCountdown()
	if not allowCountdown and isStoryMode and not seenCutscene and dialogueIsStoryMode and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/street-bg',0,0);
		setObjectCamera('cutsceneImage','dialogue')
		addLuaSprite('cutsceneImage', true)

		setProperty('inCutscene', true)
		startDialogue('dialogue')

		allowCountdown = true
		return Function_Stop
	elseif not allowCountdown and not seenCutscene and dialogueIsEverywhere and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/street-bg',0,0);
		setObjectCamera('cutsceneImage','dialogue')
		addLuaSprite('cutsceneImage', true)

		setProperty('inCutscene', true)
		startDialogue('dialogue')

		allowCountdown = true
		return Function_Stop
	end
	doTweenAlpha('cutsceneImageTween', 'cutsceneImage', 0, 1.2, 'circout')
	onTweenCompleted('cutsceneImageTween')
	runTimer('removeSprites', 1.2)
	return Function_Continue
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'removeSprites' then
		removeLuaSprite('cutsceneImage')
	end
end

function onNextDialogue(count)
	if count == 1 then
		playMusic('type', 0.8, true)
	elseif count == 6 then
		playMusic('')
	elseif count == 12 then
		playMusic('type', 0.8, true)
	end
end

function onSkipDialogue(count)
	
end