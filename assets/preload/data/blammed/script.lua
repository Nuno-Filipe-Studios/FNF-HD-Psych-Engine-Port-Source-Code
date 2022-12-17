local allowCountdown = false
function onStartCountdown()
	if PicoPlayer and not middlescroll then
		runTimer('noteTween', 0.01)
	end

	if BSIDESMODE then
		if not allowCountdown and isStoryMode and dialogueIsStoryMode and dialogueIsDisabled then
			makeLuaSprite('blackBG', 'colors/black', 0, 0)
			setObjectCamera('blackBG','dialogue')
			addLuaSprite('blackBG', true)

			makeLuaSprite('bgFade', 'colors/weirdwhite', 0, 0)
			setObjectCamera('bgFade','dialogue')
			addLuaSprite('bgFade', true)

			setProperty('bgFade.alpha', 0)
			setProperty('inCutscene', true)
			startDialogue('dialogueSecret', 'dialogue/picoMusic3', 0.9);
			doTweenAlpha('bgFadeTween', 'bgFade', 0.7, 1, 'circout')

			allowCountdown = true
			return Function_Stop
		elseif not allowCountdown and dialogueIsEverywhere and dialogueIsDisabled then
			makeLuaSprite('blackBG', 'colors/black', 0, 0)
			setObjectCamera('blackBG','dialogue')
			addLuaSprite('blackBG', true)

			makeLuaSprite('bgFade', 'colors/weirdwhite', 0, 0)
			setObjectCamera('bgFade','dialogue')
			addLuaSprite('bgFade', true)

			setProperty('bgFade.alpha', 0)
			setProperty('inCutscene', true)
			startDialogue('dialogueSecret', 'dialogue/picoMusic3', 0.9);
			doTweenAlpha('bgFadeTween', 'bgFade', 0.7, 1, 'circout')

			allowCountdown = true
			return Function_Stop
		end
		doTweenAlpha('blackBGTween', 'blackBG', 0, 1.2, 'circout')
		doTweenAlpha('bgFadeTween2', 'bgFade', 0, 1.2, 'circout')
		runTimer('removeSprites', 1.2)
		return Function_Continue
	end

	if not allowCountdown and not seenCutscene and isStoryMode and dialogueIsStoryMode and dialogueIsDisabled then
		makeLuaSprite('blackBG', 'colors/black', 0, 0)
		setObjectCamera('blackBG','dialogue')
		addLuaSprite('blackBG', true)

		makeLuaSprite('bgFade', 'colors/weirdwhite', 0, 0)
		setObjectCamera('bgFade','dialogue')
		addLuaSprite('bgFade', true)

		setProperty('bgFade.alpha', 0)
		setProperty('inCutscene', true)
		startDialogue('dialogue', 'dialogue/picoMusic3', 0.9)
		doTweenAlpha('bgFadeTween3', 'bgFade', 0.7, 1, 'circout')

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
		startDialogue('dialogue', 'dialogue/picoMusic3', 0.9)
		doTweenAlpha('bgFadeTween3', 'bgFade', 0.7, 1, 'circout')

		allowCountdown = true
		return Function_Stop
	end
	doTweenAlpha('blackBGTween2', 'blackBG', 0, 1.2, 'circout')
	doTweenAlpha('bgFadeTween4', 'bgFade', 0, 1.2, 'circout')
	runTimer('removeSprites2', 1.2)
	return Function_Continue
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'removeSprites' then
		removeLuaSprite('blackBG')
		removeLuaSprite('bgFade')
	end
	if tag == 'removeSprites2' then
		removeLuaSprite('blackBG')
		removeLuaSprite('bgFade')
	end
	if tag == 'startEndDialogue' then
		doTweenAlpha('bgFadeTween5', 'bgFade', 0.7, 1, 'circout')
		startDialogue('dialogueEnd')
	end
	if tag == 'removeSprites3' then
		removeLuaSprite('bgFade')
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
	if count == 10 then
		playMusic('')
	end
end

function onSkipDialogue(count)
	
end

local allowEndShit = false
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
		doTweenAlpha('blackBGTween3', 'blackBG', 1, 1, 'circout')
		runTimer('startEndDialogue', 0.5)

		allowEndShit = true;
		return Function_Stop;
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
		doTweenAlpha('blackBGTween3', 'blackBG', 1, 0.5, 'circout')
		runTimer('startEndDialogue', 0.5)

		allowEndShit = true;
		return Function_Stop;
	end
	doTweenAlpha('bgFadeTween6', 'bgFade', 0, 1.2, 'circout')
	runTimer('removeSprites3', 1.2)
	return Function_Continue;
end

function onNextEndDialogue(count)
	if count == 2 then
		playSound('dialogue/gunClick')
	elseif count == 8 then
		playSound('dialogue/picoWithExtraReverb')
	end
end

function onSkipEndDialogue(count)
	
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