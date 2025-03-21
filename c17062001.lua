-- neo stardus dragon by scoxta

local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.tdfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost() and c:IsRace(RACE_DRAGON)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,5,5,nil)
	if #g1==0 then return end
	Duel.HintSelection(g1,true)
	Duel.SendtoDeck(g1,nil,SEQ_DECKTOP,REASON_EFFECT)
		e:SetCategory(CATEGORY_TODECK)
		Duel.SetTargetPlayer(tp)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,1-tp,LOCATION_HAND)
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local f=Duel.GetFieldGroup(p,0,LOCATION_HAND)
		local c=e:GetHandler()
		if #f>0 then
			Duel.ConfirmCards(p,f)
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
			 sg=f:FilterSelect(p,Card.IsAbleToDeck,1,5,nil)
			local tg=Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
			Duel.ShuffleHand(1-p)
			 local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(tg*400)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
		end
end
