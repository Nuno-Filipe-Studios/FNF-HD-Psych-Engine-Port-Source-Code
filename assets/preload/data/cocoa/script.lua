local allowCountdown = false
function onStartCountdown()
	if not allowCountdown and isStoryMode and not seenCutscene and dialogueIsStoryMode and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/week5_mall', 0, 0)
		setObjectCamera('cutsceneImage', 'dialogue')
		addLuaSprite('cutsceneImage', true)

		makeLuaSprite('cutsceneImage2', 'dialogue/bg/week5_intercom1', 0, 0)
		setObjectCamera('cutsceneImage2', 'dialogue')
		addLuaSprite('cutsceneImage2', true)

		makeLuaSprite('cutsceneImage3', 'dialogue/bg/week5_screamshin', 0, 0)
		setObjectCamera('cutsceneImage3', 'dialogue')
		addLuaSprite('cutsceneImage3', true)

		makeLuaSprite('cutsceneImage4', 'dialogue/bg/week5_holdhands', 0, 0)
		setObjectCamera('cutsceneImage4', 'dialogue')
		addLuaSprite('cutsceneImage4', true)

		setProperty('cutsceneImage.visible', true)
		setProperty('cutsceneImage2.visible', false)
		setProperty('cutsceneImage3.visible', false)
		setProperty('cutsceneImage4.visible', false)
		setProperty('inCutscene', true)
		startDialogue('dialogue')

		allowCountdown = true
		return Function_Stop
	elseif not allowCountdown and not seenCutscene and dialogueIsEverywhere and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/week5_mall', 0, 0)
		setObjectCamera('cutsceneImage', 'dialogue')
		addLuaSprite('cutsceneImage', true)

		makeLuaSprite('cutsceneImage2', 'dialogue/bg/week5_intercom1', 0, 0)
		setObjectCamera('cutsceneImage2', 'dialogue')
		addLuaSprite('cutsceneImage2', true)

		makeLuaSprite('cutsceneImage3', 'dialogue/bg/week5_screamshin', 0, 0)
		setObjectCamera('cutsceneImage3', 'dialogue')
		addLuaSprite('cutsceneImage3', true)

		makeLuaSprite('cutsceneImage4', 'dialogue/bg/week5_holdhands', 0, 0)
		setObjectCamera('cutsceneImage4', 'dialogue')
		addLuaSprite('cutsceneImage4', true)

		setProperty('cutsceneImage.visible', true)
		setProperty('cutsceneImage2.visible', false)
		setProperty('cutsceneImage3.visible', false)
		setProperty('cutsceneImage4.visible', false)
		setProperty('inCutscene', true)
		startDialogue('dialogue')

		allowCountdown = true
		return Function_Stop
	end
	doTweenAlpha('cutsceneImageTween', 'cutsceneImage', 0, 1.2, 'circout')
	doTweenAlpha('cutsceneImageTween2', 'cutsceneImage2', 0, 1.2, 'circout')
	doTweenAlpha('cutsceneImageTween3', 'cutsceneImage3', 0, 1.2, 'circout')
	doTweenAlpha('cutsceneImageTween4', 'cutsceneImage4', 0, 1.2, 'circout')
	runTimer('removeSprites', 1.2)
	return Function_Continue
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'removeSprites' then
		removeLuaSprite('cutsceneImage')
		removeLuaSprite('cutsceneImage2')
		removeLuaSprite('cutsceneImage3')
		removeLuaSprite('cutsceneImage4')
	end
end

function onNextDialogue(count)
	if count == 1 then
		removeLuaSprite('cutsceneImage')
		setProperty('cutsceneImage2.visible', true)
	elseif count == 12 then
		removeLuaSprite('cutsceneImage2')
		setProperty('cutsceneImage3.visible', true)
	elseif count == 13 then
		removeLuaSprite('cutsceneImage3')
		setProperty('cutsceneImage4.visible', true)
	end
end

function onSkipDialogue(count)
	
end