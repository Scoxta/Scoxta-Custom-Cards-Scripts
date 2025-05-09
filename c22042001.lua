--Nocturne Eyes

local s,id=GetID()
function s.initial_effect(c)

	--Special If Pluto
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	--e2:SetCondition(s.reccon)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
end
s.listed_names={24413299}

function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(24413299)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end


function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(tp,g)
			if Duel.IsExistingMatchingCard(Card.IsSpell,tp,0,LOCATION_HAND,1,nil) then 
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
				Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
			end
	end
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
