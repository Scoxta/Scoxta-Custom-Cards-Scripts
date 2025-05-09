--Deck Master Custom System by Scoxta
local s,id=GetID()
function s.initial_effect(c)
	local e20=Effect.GlobalEffect()
	e20:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e20:SetCode(EVENT_STARTUP)
	e20:SetCountLimit(1)
	e20:SetOperation(s.VirtualWorldStart)
	Duel.RegisterEffect(e20, 0)
end



function s.VirtualWorldStart()
	if Duel.GetFlagEffect(0, id) ~= 0 then return end
	Duel.RegisterFlagEffect(0, id, 0, 0, 0)

	-- Efecto 1: Face-up Def
	local e100=Effect.GlobalEffect()
	e100:SetType(EFFECT_TYPE_FIELD)
	e100:SetCode(EFFECT_LIGHT_OF_INTERVENTION)
	e100:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e100:SetTargetRange(1,1)
	Duel.RegisterEffect(e100,0)

	-- Efecto 2: Cannot Attack
	local e101=Effect.GlobalEffect()
	e101:SetType(EFFECT_TYPE_FIELD)
	e101:SetCode(EFFECT_CANNOT_ATTACK)
	e101:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e101:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e101:SetTarget(function(e,c)
		return c:IsStatus(STATUS_SPSUMMON_TURN) and
			(c:IsSummonLocation(LOCATION_EXTRA) or (c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsSummonLocation(LOCATION_GRAVE))) and
			not c:IsHasEffect(511004016)
	end)
	Duel.RegisterEffect(e101,0)

	-- Deck Master Scoxta Setup
	local dm=Duel.CreateToken(0,21122023)
	Duel.Hint(HINT_CARD,0,21122023)
	DeckMaster.RegisterRules(dm)
end













if not DeckMaster then
	DeckMaster={}
	DeckMaster[0]={}
	DeckMaster[1]={}
	DeckMasterZone={}
	FLAG_DECK_MASTER = id

	--function that return the flag that check if a monster is treated as a Deck Master
	function Card.IsDeckMaster(c)
		return c:GetFlagEffect(FLAG_DECK_MASTER)>0
	end
	--function that get the Deck Master of player
	function Duel.GetDeckMaster(p)
		return DeckMasterZone[p] or Duel.GetMatchingGroup(Card.IsDeckMaster,p,LOCATION_MZONE,0,nil):GetFirst()
	end
	--function that return the Deck Master of player
	function Duel.IsDeckMaster(p,code)
		return Duel.GetDeckMaster(p) and Duel.GetDeckMaster(p):IsOriginalCode(code)
	end
	-- function that send a card to the DM zone
	-- add the card to the Skill zone, register the DMzone flag then send the card to limbo
	function Card.MoveToDeckMasterZone(c,p)
		Duel.DisableShuffleCheck()
		Duel.SendtoDeck(c,nil,-2,REASON_RULE)
		Duel.Hint(HINT_SKILL_FLIP,p,c:GetOriginalCode()|(1<<32))
		DeckMasterZone[p]=c
	end
	--function that remove the card from the DM/Skill zone
	function Duel.ClearDeckMasterZone(p)
		local c=DeckMasterZone[p]
		if not c then return end
		Duel.Hint(HINT_SKILL_REMOVE,p,c:GetOriginalCode())
		DeckMasterZone[p]=nil
	end
	--function that summon the monster from the DMzone
	--remove from DMzone, remove the DMzone flag, summon the deck master

--RESET_TOFIELD to handle move between S/T and M (maybe change later?)
--RESET_CONTROL to handle control change which will cause Deck Master no longer Deck Master
--Xyz Material is handled by field check automatically
	function Duel.SummonDeckMaster(p)
		local c=DeckMasterZone[p]
		if not c then return false end
		Duel.ClearDeckMasterZone(p)
		local res=Duel.SpecialSummon(c,0,p,p,false,false,POS_FACEUP)
		c:RegisterFlagEffect(FLAG_DECK_MASTER,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_CONTROL,EFFECT_FLAG_CLIENT_HINT,1,nil,aux.Stringid(FLAG_DECK_MASTER,0))
		return res
	end
	function DeckMaster.RegisterAbilities(c,...)
		local deckMasterEffects={...}
		local e0=Effect.GlobalEffect()
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_ADJUST)
		e0:SetOperation(function(e)
			local id=c:GetOriginalCode()
			if not DeckMaster[c:GetOwner()][id] then
				DeckMaster[c:GetOwner()][id]=true
				for _,eff in ipairs(deckMasterEffects) do
					Duel.RegisterEffect(eff:Clone(),c:GetOwner())
				end
			end
			e:Reset()
		end)
		Duel.RegisterEffect(e0,0)
	end

	function DeckMaster.RegisterRules(c)
		for p=0,1 do
			Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(FLAG_DECK_MASTER,1))
			local dmc=Duel.SelectCardsFromCodes(p,1,1,false,false,table.unpack(DeckMasterTableSelect))
			local dg=Duel.GetMatchingGroup(Card.IsOriginalCode,p,LOCATION_ALL,0,nil,dmc)
			if #dg==3 then
				Duel.Hint(HINT_MESSAGE,p,aux.Stringid(FLAG_DECK_MASTER,2))
				Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(FLAG_DECK_MASTER,4))
				local burn=dg:Select(p,1,1,nil)
				Duel.SendtoDeck(burn,nil,-2,REASON_RULE)
			elseif #dg>0 and Duel.SelectYesNo(p,aux.Stringid(FLAG_DECK_MASTER,3)) then
				Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(FLAG_DECK_MASTER,4))
				local burn=dg:Select(p,1,1,nil)
				Duel.SendtoDeck(burn,nil,-2,REASON_RULE)
			end
			local t=Duel.CreateToken(p,dmc)
			t:MoveToDeckMasterZone(p)
			-- Eliminar copias de esta carta tras elegir el Deck Master
			for p=0,1 do
				local g=Duel.GetMatchingGroup(Card.IsCode, p, LOCATION_HAND+LOCATION_DECK, 0, nil, FLAG_DECK_MASTER)
				if #g > 0 then
					local hand_cards = g:Filter(Card.IsLocation, nil, LOCATION_HAND)
					Duel.SendtoDeck(g, nil, -2, REASON_RULE)
					if #hand_cards > 0 then
						Duel.Draw(p, #hand_cards, REASON_RULE)
					end
				end
			end
		end
		--Summon Deck Master
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCondition(DeckMaster.spcon)
		e1:SetOperation(DeckMaster.spop)
		Duel.RegisterEffect(e1,0)
		local e2=e1:Clone()
		Duel.RegisterEffect(e2,1)
		--Lose
		local e3=Effect.GlobalEffect()
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e3:SetCountLimit(1)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e3:SetOperation(DeckMaster.loss)
		Duel.RegisterEffect(e3,0)
		local e4=e3:Clone()
		e4:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
		Duel.RegisterEffect(e4,0)
		local e5=e3:Clone()
		e5:SetCode(EVENT_PHASE_START+PHASE_MAIN1)
		Duel.RegisterEffect(e5,0)
		local e6=e3:Clone()
		e6:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
		Duel.RegisterEffect(e6,0)
		local e7=e3:Clone()
		e7:SetCode(EVENT_PHASE_START+PHASE_MAIN2)
		Duel.RegisterEffect(e7,0)
		local e8=e3:Clone()
		e8:SetCode(EVENT_PHASE_START+PHASE_END)
		Duel.RegisterEffect(e8,0)
		
		local e13=Effect.CreateEffect(c)
		e13:SetType(EFFECT_TYPE_CONTINUOUS)
		e13:SetCode(EFFECT_CANNOT_LOSE_EFFECT)
		e13:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e13:SetTargetRange(1,1)
		e13:SetLabelObject(rc)
		e13:SetLabel(1)
		Duel.RegisterEffect(e13,0)
		local ePreventFatalAttack=Effect.GlobalEffect()
		ePreventFatalAttack:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ePreventFatalAttack:SetCode(EVENT_ATTACK_ANNOUNCE)
		ePreventFatalAttack:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local a=Duel.GetAttacker()
		local d=Duel.GetAttackTarget()
		if not a or not a:IsRelateToBattle() or a:IsDeckMaster() then return end
		local atk = a:GetAttack()
		local def_player = 1 - a:GetControler()
		local lp = Duel.GetLP(def_player)
			if d==nil then
				-- ataque directo
				if atk >= lp then
					Duel.NegateAttack()
				end
			else
				-- ataque a un monstruo
				if a:IsAttackPos() and d:IsAttackPos() then
					local dmg = math.max(0, atk - d:GetAttack())
					if dmg >= lp then
						Duel.NegateAttack()
					end
				end
			end
		end)
		Duel.RegisterEffect(ePreventFatalAttack, 0)


		local eNegate=Effect.GlobalEffect()
		eNegate:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		eNegate:SetCode(EVENT_CHAIN_SOLVING)
		eNegate:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local rc=re:GetHandler()
		if rc:IsCode(12580477) then  -- ← reemplazá 00000000 por el código de la carta que quieras negar
			Duel.NegateEffect(ev)
				end
		end)
		Duel.RegisterEffect(eNegate, 0)
		for _,code in ipairs({
		EFFECT_CANNOT_LOSE_EFFECT,
		EFFECT_CANNOT_WIN_EFFECT,
		EFFECT_CANNOT_DRAW
	}) do
		local e=Effect.GlobalEffect()
		e:SetType(EFFECT_TYPE_FIELD)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e:SetCode(code)
		e:SetTargetRange(1,1) -- ambos jugadores
		Duel.RegisterEffect(e, 0)
	end
	end
	function DeckMaster.spcon(e,tp,eg,ep,ev,re,r,rp)
		local dm=DeckMasterZone[tp]
		return Duel.IsMainPhase() and dm and dm:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	function DeckMaster.spop(e,tp,eg,ep,ev,re,r,rp)
		if not Duel.SelectYesNo(tp,aux.Stringid(FLAG_DECK_MASTER,5)) then return end
		Duel.SummonDeckMaster(tp)
	end
	function DeckMaster.inheritcon1(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(Card.IsDeckMaster,1,nil)
	end
	function DeckMaster.inheritop1(e,tp,eg,ep,ev,re,r,rp)
		local g=eg:Filter(Card.IsDeckMaster,nil)
		for tc in aux.Next(g) do
			if tc:GetReason()&REASON_BATTLE==0 and tc:GetReasonCard() then
				tc:GetReasonCard():RegisterFlagEffect(FLAG_DECK_MASTER,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_CONTROL,EFFECT_FLAG_CLIENT_HINT,1,nil,aux.Stringid(FLAG_DECK_MASTER,0))
			end
		end
	end
	function DeckMaster.inheritFilter(c)
		return not Duel.GetDeckMaster(c:GetControler()) and c:GetControler()==c:GetSummonPlayer()
	end
	function DeckMaster.inheritcon2(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(DeckMaster.inheritFilter,1,nil)
	end
	function DeckMaster.inheritop2(e,tp,eg,ep,ev,re,r,rp)
		local g=eg:Filter(DeckMaster.inheritFilter,nil)
		for p=0,1 do
			local dg=g:Filter(Card.IsControler,nil,p)
			if #dg>0 then
				Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(FLAG_DECK_MASTER,4))
				local dm=dg:Select(p,1,1,nil):GetFirst()
				dm:RegisterFlagEffect(FLAG_DECK_MASTER,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_CONTROL,EFFECT_FLAG_CLIENT_HINT,1,nil,aux.Stringid(FLAG_DECK_MASTER,0))
			end
		end
	end
	function DeckMaster.loss(e,tp,eg,ep,ev,re,r,rp)
		local dm1 = DeckMasterZone[0]
		local dm2 = DeckMasterZone[1]

		-- Verificamos si están presentes en alguna zona
		if dm1 and not dm1:IsLocation(LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA) then
			dm1 = nil
		end
		if dm2 and not dm2:IsLocation(LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA) then
			dm2 = nil
		end

		if not dm1 and dm2 then
			Duel.ResetFlagEffect(0, EFFECT_CANNOT_LOSE_EFFECT)
			Duel.Win(1, 0x21)
		elseif dm1 and not dm2 then
			Duel.ResetFlagEffect(1, EFFECT_CANNOT_LOSE_EFFECT)
			Duel.Win(0, 0x21)
		elseif not dm1 and not dm2 then
			Duel.ResetFlagEffect(0, EFFECT_CANNOT_LOSE_EFFECT)
			Duel.ResetFlagEffect(1, EFFECT_CANNOT_LOSE_EFFECT)
			Duel.Win(PLAYER_NONE, 0x21)
		end
	end

	DeckMasterTableSelect={20721928,84327329,58932615,21844576,79979666,89252153}
	DeckMasterTable={20721928,84327329,58932615,21844576,85188410,79979555,89252153}
end
