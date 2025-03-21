--Mochi Card
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	--e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	--e1:SetRange(0xff)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

end
--function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
--	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
--	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
--	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
--	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
--	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
--end
--function s.activate(e,tp,eg,ep,ev,re,r,rp)
--	local tc=Duel.GetFirstTarget()
--	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
--	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
--	if tc and tc:IsRelateToEffect(e) then
--		Duel.Destroy(tc,REASON_EFFECT)
--	end
--end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsType(TYPE_MONSTER) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,TYPE_MONSTER)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetChainLimit(aux.FALSE)
end
--function s.activate(e,tp,eg,ep,ev,re,r,rp)
--	local tc=Duel.GetFirstTarget()
--	if tc and tc:IsRelateToEffect(e) then
--		--Desaparece del Duelo LIT
--		Duel.SendtoDeck(tc,nil,-2,REASON_RULE)
--		s.drawtarget(e,tp,eg,ep,ev,re,r,rp,chk)
--	end
--end
function s.drawtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)==0 then
		local sdg=Duel.GetMatchingGroup(Card.IsCode,tp,0x7f,0x7f,nil,id)
		Duel.SendtoDeck(sdg,nil,-2,REASON_RULE)
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		Duel.ConfirmCards(1-tp,c)
		Duel.Hint(HINT_CARD,0,id)
	end
	Duel.DisableShuffleCheck()
	Duel.SendtoDeck(c,nil,-2,REASON_RULE)
	if c:GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp,1,REASON_RULE)
	end
end
function s.filter(c,e)
	return c:IsFaceup()
end
--function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
--	if chkc then return eg:IsContains(chkc) end
--	if chk==0 then return eg:IsExists(s.filter,1,nil,e) end
--	if #eg==1 then
--		Duel.SetTargetCard(eg)
--	else
--		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
--		local g=eg:FilterSelect(tp,s.filter,1,1,nil,e)
--		Duel.SetTargetCard(g)
--	end
--end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	overout(e,tp,eg,ep,ev,re,r,rp)
	local tpe=tc:GetType()
	if (tpe&TYPE_TOKEN)~=0 then return end
	local dg=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ALL,0,nil,tc:GetCode())
	local dg2=Duel.GetMatchingGroup(Card.IsCode,tp-1,LOCATION_ALL,0,nil,tc:GetCode())
	Duel.SendtoDeck(dg,nil,-2,REASON_RULE)
	Duel.SendtoDeck(dg2,nil,-2,REASON_RULE)

end

function overout(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	tc:RemoveOverlayCard(tp,tc:GetOverlayCount(),tc:GetOverlayCount(),REASON_EFFECT)	
end