--uno para TODOS!
local selfs={}
if self_table then
	function self_table.initial_effect(c) table.insert(selfs,c) end
end
local id=19062031
if self_code then id=self_code end
local s,id=GetID()
local function finish_setup()
		--Pre-draw
		local e1=Effect.GlobalEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_STARTUP)
		e1:SetCountLimit(1)
		e1:SetOperation(sactivate)
		Duel.RegisterEffect(e1,0)
	end
function s.initial_effect(c)
local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
			e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e2:SetCode(EFFECT_SELF_DESTROY)
			e2:SetCondition(s.sdcon)
			c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsCode(19062031) 
end
function s.sdcon(e)
	return Duel.IsExistingMatchingCard(s.filter,0,LOCATION_ALL,1,nil) 
end

function sactivate(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.filter,1-tp,0,LOCATION_ALL,nil)
	local getrc=Card.GetRace
			Card.GetRace=function(c)
				if c:IsMonster() then return 0xfffffff end
				return getrc(c)
			end
			local getorigrc=Card.GetOriginalRace
			Card.GetOriginalRace=function(c)
				if c:IsMonster() then return 0xfffffff end
				return getorigrc(c)
			end
			local getprevrc=Card.GetPreviousRaceOnField
			Card.GetPreviousRaceOnField=function(c)
				if (c:GetPreviousTypeOnField()&TYPE_MONSTER)~=0 then return 0xfffffff end
				return getprevrc(c)
			end
			local isrc=Card.IsRace
			Card.IsRace=function(c,r)
				if c:IsMonster() then return true end
				return isrc(c,r)
			end
			if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
			Duel.SetTargetPlayer(tp)
			Duel.SetTargetParam(1)
			Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
			local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
			--Duel.Draw(p,d,REASON_EFFECT)
			Duel.SendtoDeck(g,1-tp,-2,REASON_RULE)
			
end


finish_setup()

			

		