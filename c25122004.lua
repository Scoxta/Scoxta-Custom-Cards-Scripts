local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddEquipProcedure(c,nil,function(c)
		return c:IsSetCard(0x1F5) or c:IsCode(64268668)
	end )
	--Atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--change name
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(64268668,0))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCondition(s.ccon)
	e5:SetOperation(s.cop)
	c:RegisterEffect(e5)
end
s.listed_series={0x30}

function s.ccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
end
function s.cop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(64268668)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
