local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	--e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--GY Effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	--e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	--e2:SetCountLimit(1,id)
	--e2:SetCondition(aux.exccon)
	e2:SetCost(s.cost2)
	--e2:SetTarget(s.destg)
	e2:SetOperation(s.mill)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL,30208479}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_DARK_MAGICIAN_GIRL),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.filter(c,e,tp)
	return c:IsCode(CARD_DARK_MAGICIAN_GIRL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if ht<6 then 
		Duel.Draw(tp,6-ht,REASON_EFFECT)
		end
		ht=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
		if ht<6 then 
		Duel.Draw(1-tp,6-ht,REASON_EFFECT)
		end
	end
end
function s.cfilter(c)
	return c:IsCode(CARD_DARK_MAGICIAN) or c:IsCode(30208479)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.mill(e,tp,eg,ep,ev,re,r,rp)
	 g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil)
	if dr~=0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,3,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
