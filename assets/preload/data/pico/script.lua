local allowCountdown = false
function onStartCountdown()
	if PicoPlayer and not middlescroll then
		runTimer('noteTween', 0.01)
	end
	
	if not allowCountdown and not seenCutscene and isStoryMode and dialogueIsStoryMode and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/picoweek1',0,0);
		setObjectCamera('cutsceneImage','dialogue')
		addLuaSprite('cutsceneImage', true)

		makeLuaSprite('cutsceneImage2', 'dialogue/bg/picoweek2',0,0);
		setObjectCamera('cutsceneImage2','dialogue')
		addLuaSprite('cutsceneImage2', true)

		setProperty('cutsceneImage.visible', true)
		setProperty('cutsceneImage2.visible', false)
		setProperty('inCutscene', true);
		startDialogue('dialogue', 'dialogue/dateTypeBeat', 0.8);

		allowCountdown = true;
		return Function_Stop;
	elseif not allowCountdown and not seenCutscene and dialogueIsEverywhere and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/picoweek1',0,0);
		setObjectCamera('cutsceneImage','dialogue')
		addLuaSprite('cutsceneImage', true)

		makeLuaSprite('cutsceneImage2', 'dialogue/bg/picoweek2',0,0);
		setObjectCamera('cutsceneImage2','dialogue')
		addLuaSprite('cutsceneImage2', true)

		setProperty('cutsceneImage.visible', true)
		setProperty('cutsceneImage2.visible', false)
		setProperty('inCutscene', true);
		startDialogue('dialogue', 'dialogue/dateTypeBeat', 0.8);

		allowCountdown = true;
		return Function_Stop;
	end
	doTweenAlpha('cutsceneImageTween', 'cutsceneImage', 0, 1.2, 'circout')
	doTweenAlpha('cutsceneImageTween2', 'cutsceneImage2', 0, 1.2, 'circout')
	runTimer('removeSprites', 1.2)
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'removeSprites' then
		removeLuaSprite('cutsceneImage')
		removeLuaSprite('cutsceneImage2')
	end
	if tag == 'removeSprites2' then
		removeLuaSprite('blackBG')
	end
	if tag == 'removeSprites3' then
		removeLuaSprite('blackBG2')
	end
	if tag == 'noteTween' then
		noteTweenX('noteTween1', 4, 93, 0.01, cubein)
		noteTweenX('noteTween2', 5, 204, 0.01, cubein)
		noteTweenX('noteTween3', 6, 316, 0.01, cubein)
		noteTweenX('noteTween4', 7, 429, 0.01, cubein)
		noteTweenX('noteTween5', 0, 733, 0.01, cubeout)
		noteTweenX('noteTween6', 1, 844, 0.01, cubeout)
		noteTweenX('noteTween7', 2, 956, 0.01, cubeout)
		noteTweenX('noteTween8', 3, 1068, 0.01, cubeout)
	end
end

function onNextDialogue(count)
	if count == 7 then
		setProperty('cutsceneImage.visible', false)
		setProperty('cutsceneImage2.visible', true)
		playMusic('')
		playSound('dialogue/gunClick')
	elseif count == 8 then
		playMusic('dialogue/picoMusic1', 0.9, true)
	end
end

function onSkipDialogue(count)
	
end

function onUpdatePost()
	if PicoPlayer then
		P1Mult = getProperty('healthBar.x') + ((getProperty('healthBar.width') * getProperty('healthBar.percent') * 0.01) + (150 * getProperty('iconP1.scale.x') - 150) / 2 - 26)
		P2Mult = getProperty('healthBar.x') + ((getProperty('healthBar.width') * getProperty('healthBar.percent') * 0.01) - (150 * getProperty('iconP2.scale.x')) / 2 - 26 * 2)

		setProperty('iconP1.x', P1Mult - 101)
		setProperty('iconP2.x', P2Mult + 101)
		setProperty('iconP1.origin.x', 240)
		setProperty('iconP2.origin.x', -100)
		setProperty('iconP1.flipX',true)
		setProperty('iconP2.flipX',true)
		setProperty('healthBar.flipX',true)
	end
end