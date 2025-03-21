--ディープスペース・ユグドラゴ
--Full armor Rage Dragon
--Scripted by Scoxta
local s,id=GetID()
function s.initial_effect(c)
	Fusion.AddProcMixN(c,true,true,160205056,1,s.ffilter,1)
	--Gana Ataque
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--No trampas
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_ONFIELD,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,1,LOCATION_MZONE,0,nil)
	return g:GetSum(Card.GetLevel)*300+3200 +g2:GetSum(Card.GetLevel)*300
end
function s.ffilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_MAXIMUM,fc,sumtype,tp)
end


function s.cfilter(c,code)
	return c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_DINOSAUR) and c:IsLevel(10) and c:IsType(TYPE_MAXIMUM)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	if g:FilterCount(s.cfilter,nil,nil)>0 then
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(0,1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function() return Duel.IsBattlePhase() end)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsTrap() and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end