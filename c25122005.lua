local s,id=GetID()
function s.initial_effect(c)
	-- Link summon con una sola función que permita ambos tipos de material
	Link.AddProcedure(c, function(c)
		return c:IsSetCard(0x1F5) or c:IsCode(64268668)
	end, 3)
	c:EnableReviveLimit()

	-- Usar un monstruo del oponente con la serie 0x1F5 o código 64268668 como material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_EXTRA_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(1,1)
	e0:SetOperation(s.extracon)
	e0:SetValue(s.extraval)
	c:RegisterEffect(e0)

	-- Efecto de invocar un monstruo Ogre desde el Cementerio al ser invocado por Link
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetTarget(s.fuselist_tg)
	e2:SetOperation(s.fuselist_op)
	c:RegisterEffect(e2)




end

s.listed_names={64268668} -- Ahora el Link reconoce Cyber Ogre como material válido

s.curgroup=nil

s.fusion_targets = {
    37057012, -- Cyber Ogre 2
    25122001, -- Cyber Ogre 3
    -- Podés agregar más códigos acá
}

-- Filtrar monstruos del oponente que sean de la serie 0x1F5 o `64268668`
function s.filter(c)
	return c:IsFaceup() and (c:IsSetCard(0x1F5) or c:IsCode(64268668))
end

-- Verificar si los materiales extra son válidos
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	if not s.curgroup then return true end
	local g=s.curgroup:Filter(Card.IsFaceup,nil)
	return #(sg&g)<2 -- Permite solo 1 material del oponente
end

function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			-- Obtener solo monstruos del oponente que sean válidos
			s.curgroup=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
			s.curgroup:KeepAlive()
			return s.curgroup
		end
	elseif chk==2 then
		-- Borrar el grupo cuando ya no sea necesario
		if s.curgroup then
			s.curgroup:DeleteGroup()
		end
		s.curgroup=nil
	end
end

-- Condición para activar el efecto al ser invocado por Link
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- Filtro para seleccionar un monstruo "Ogre" en el Cementerio
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x1F5) or c:IsCode(64268668)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Seleccionar el objetivo en el Cementerio
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

-- Invocar un monstruo "Ogre" desde el Cementerio
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if sc then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
--uwu 
function s.fuselist_filter(c,e,tp)
	for _,code in ipairs(s.fusion_targets) do
		if c:IsCode(code) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) then
			return true
		end
	end
	return false
end

function s.fuselist_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local deckMat=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_DECK+LOCATION_ONFIELD,0,nil)
		return Duel.IsExistingMatchingCard(s.fuselist_filter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_ONFIELD)
end

function s.fuselist_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.fuselist_filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local fc=g:GetFirst()
	if not fc then return end

	local matCodes = {}
	if fc:IsCode(37057012) then -- Cyber Ogre 2
		matCodes = {64268668,64268668}
	elseif fc:IsCode(25122001) then -- Cyber Ogre 3
		matCodes = {64268668,64268668,64268668}
	else
		return -- No está soportada
	end

	local all_mat=Duel.GetMatchingGroup(function(c)
		return c:IsCode(64268668) and c:IsAbleToGrave() and c:IsCanBeFusionMaterial(fc,e)
	end, tp, LOCATION_DECK+LOCATION_ONFIELD, 0, nil)

	if #all_mat < #matCodes then return end

	local selected=Group.CreateGroup()
	local count_needed=#matCodes
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)

	for i=1,count_needed do
		local pick=all_mat:Select(tp,1,1,nil):GetFirst()
		if not pick then return end
		selected:AddCard(pick)
		all_mat:RemoveCard(pick) -- evita repetir
	end

	if #selected == count_needed then
		fc:SetMaterial(selected)
		Duel.SendtoGrave(selected,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.BreakEffect()
		Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		fc:CompleteProcedure()
	end
end

