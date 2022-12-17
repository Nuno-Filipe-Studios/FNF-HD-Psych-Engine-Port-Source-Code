local allowCountdown = false
function onStartCountdown()
	if not allowCountdown and isStoryMode and not seenCutscene and dialogueIsStoryMode and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/news1', 0, 0);
		setObjectCamera('cutsceneImage','dialogue')
		addLuaSprite('cutsceneImage', true)

		makeLuaSprite('cutsceneImage2', 'dialogue/bg/news2', 0, 0);
		setObjectCamera('cutsceneImage2','dialogue')
		addLuaSprite('cutsceneImage2', true)

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
		playSound('dialogue/news/1', 1, 'news1')

		allowCountdown = true
		return Function_Stop
	elseif not allowCountdown and not seenCutscene and dialogueIsEverywhere and dialogueIsDisabled then
		makeLuaSprite('cutsceneImage', 'dialogue/bg/news1', 0, 0);
		setObjectCamera('cutsceneImage','dialogue')
		addLuaSprite('cutsceneImage', true)

		makeLuaSprite('cutsceneImage2', 'dialogue/bg/news2', 0, 0);
		setObjectCamera('cutsceneImage2','dialogue')
		addLuaSprite('cutsceneImage2', true)

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
		playSound('dialogue/news/1', 1, 'news1')

		allowCountdown = true
		return Function_Stop
	end
	doTweenAlpha('cutsceneImageTween', 'cutsceneImage', 0, 1.2, 'circout')
	doTweenAlpha('cutsceneImageTween2', 'cutsceneImage2', 0, 1.2, 'circout')
	doTweenAlpha('blackBGTween', 'blackBG', 0, 1.2, 'circout')
	doTweenAlpha('bgFadeTween', 'bgFade', 0, 1.2, 'circout')
	soundFadeOut('news1', 1, 0)
	soundFadeOut('news2', 1, 0)
	soundFadeOut('news3', 1, 0)
	soundFadeOut('news4', 1, 0)
	soundFadeOut('news5', 1, 0)
	soundFadeOut('news6', 1, 0)
	soundFadeOut('news7', 1, 0)
	soundFadeOut('news8', 1, 0)
	soundFadeOut('news9', 1, 0)
	runTimer('removeSprites', 1.2)
	runTimer('removeSounds', 1)
	return Function_Continue
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'removeSprites' then
		removeLuaSprite('cutsceneImage', true)
		removeLuaSprite('cutsceneImage2', true)
		removeLuaSprite('blackBG', true)
	end
	if tag == 'removeSounds' then
		stopSound('news1')
		stopSound('news2')
		stopSound('news3')
		stopSound('news4')
		stopSound('news5')
		stopSound('news6')
		stopSound('news7')
		stopSound('news8')
		stopSound('news9')
	end
end

function onNextDialogue(count)
	if count == 1 then
		stopSound('news1')
		playSound('dialogue/news/2', 1, 'news2')
	elseif count == 2 then
		stopSound('news2')
		playSound('dialogue/news/3', 1, 'news3')
	elseif count == 3 then
		setProperty('cutsceneImage.visible', false)
		setProperty('cutsceneImage2.visible', true)
		stopSound('news3')
		playSound('dialogue/news/4', 1, 'news4')
	elseif count == 4 then
		setProperty('cutsceneImage.visible', true)
		setProperty('cutsceneImage2.visible', false)
		stopSound('news4')
		playSound('dialogue/news/5', 1, 'news5')
	elseif count == 5 then
		stopSound('news5')
		playSound('dialogue/news/6', 1, 'news6')
	elseif count == 6 then
		setProperty('cutsceneImage.visible', false)
		setProperty('cutsceneImage2.visible', true)
		stopSound('news6')
		playSound('dialogue/news/7', 1, 'news7')
	elseif count == 7 then
		setProperty('cutsceneImage.visible', true)
		setProperty('cutsceneImage2.visible', false)
		stopSound('news7')
		playSound('dialogue/news/8', 1, 'news8')
	elseif count == 8 then
		removeLuaSprite('cutsceneImage', true)
		setProperty('cutsceneImage2.visible', true)
		stopSound('news8')
		playSound('dialogue/news/9', 1, 'news9')
	elseif count == 9 then
		removeLuaSprite('cutsceneImage2', true)
		setProperty('blackBG.visible', true)
		setProperty('bgFade.visible', true)
		stopSound('news9')
		playMusic('dialogue/mommiTalki', 0.9, true)
	end
end

function onSkipDialogue(count)
	
end