--Disparo de Heroe
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_SZONE+LOCATION_HAND)
	e1:SetCondition(s.discon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end
s.listed_series={0x8,0x3008}
s.listed_series2={0x3008}
s.listed_names={20721928}
-- 0x8 Hero Code --
-- 0x3008 Elemental Hero Code
--negation
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and MainPhaseCheck() or MainPhase2Check()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8)
end
function s.cfilter2(c)
	return c:ListsCodeWithArchetype(c,0x3008)
end
function s.costfilter(c,e)
	return c:IsSetCard(0x8) and c:IsMonster()
end
function s.costfilter2(c,e)
	return c:IsSetCard(0x3008) and c:IsMonster() 
end
function sparkmanfilter(c,e)
	return c:IsFaceup() and c:IsCode(20721928)
end
function s.filter(c,e)
	return (c:IsSetCard(0x8) and c:IsMonster())
end
function MainPhaseCheck()
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
function MainPhase2Check()
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ft)
	--Duel.Release(g,REASON_COST)
	if Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp,ft) then
		if Duel.IsExistingMatchingCard(sparkmanfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,ft) then
		Duel.Release(g,REASON_COST)
		s.damtg(e,tp,eg,ep,ev,re,r,rp)
		return s.drawtarget(e,tp,eg,ep,ev,re,r,rp,chk) 
		else Duel.Release(g,REASON_COST)
		end
	return s.damtg(e,tp,eg,ep,ev,re,r,rp)
	else Duel.Release(g,REASON_COST)	
	end
end


function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(800)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.drawtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end