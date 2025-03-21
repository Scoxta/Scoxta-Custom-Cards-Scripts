---hydro Dragon XYZ

local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),7,2,s.ovfilter,aux.Stringid(id,0),nil,s.xyzop)
	c:EnableReviveLimit()
	--
local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	--e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end

s.listed_series={0x1F4}
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(0x1F4,lc,SUMMON_TYPE_XYZ,tp) and not c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,id)
end


function s.operation(e,tp,eg,ep,ev,re,r,rp )
	z=Duel.GetMatchingGroupCount(nil,1-tp,0,LOCATION_ALL,nil)*77
	Duel.Damage(1-tp,z,REASON_EFFECT)
end