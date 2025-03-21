-- Aquí definimos la función GetID para obtener el ID del efecto actual
local s, id = GetID()

-- Función principal que define los efectos de la carta
function s.initial_effect(c)
    -- Efecto de activación principal
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Efecto para añadir una copia al campo del oponente cuando se envía al cementerio
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetOperation(s.addop)
    c:RegisterEffect(e2)

    -- Efecto para remover cartas y ganar vida desde el cementerio
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_REMOVE + CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCost(s.rmcost)
    e3:SetTarget(s.rmtarget)
    e3:SetOperation(s.rmactivate)
    c:RegisterEffect(e3)
end

-- Función para el costo de activación (pagar 1000 LP)
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

-- Función para filtrar monstruos que se pueden Invocar de manera especial
function s.spfilter(c, e, tp)
    return (c:IsCanBeSpecialSummoned(e, 0, tp, true, false) or c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, true, false))
           and c:IsType(TYPE_MONSTER)
end

-- Función de objetivo para la activación
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
               and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK + LOCATION_EXTRA)
end

-- Función de operación para la activación principal
function s.activate(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, true, false, POS_FACEUP)
        s.activate2(e, tp, eg, ep, ev, re, r, rp)  -- Llamada directa a activate2 sin esperar un valor de retorno
    end
end

-- Función para añadir una copia al campo del oponente cuando se envía al cementerio
function s.addop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsReason(REASON_DESTROY) or c:IsReason(REASON_EFFECT) then
        Duel.Hint(HINT_CARD, tp, id)
        local token = Duel.CreateToken(tp, id)
        Duel.SendtoHand(token, 1 - tp, REASON_EFFECT)
        Duel.ConfirmCards(tp, token)
    end
end

-- Función para el costo de remover cartas desde el cementerio
function s.rmcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.rmfilter, tp, LOCATION_GRAVE, 0, 2, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.rmfilter, tp, LOCATION_GRAVE, 0, 2, 2, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

-- Función de filtro para el costo de remover cartas
function s.rmfilter(c)
    return c:IsCode(id) and c:IsAbleToRemoveAsCost()
end

-- Función de objetivo para remover cartas y ganar vida
function s.rmtarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 3000)
end

-- Función de operación para remover cartas y ganar vida
function s.rmactivate(e, tp, eg, ep, ev, re, r, rp)
    Duel.Recover(tp, 3000, REASON_EFFECT)
end

-- Función para añadir una carta específica al Extra Deck
function s.activate2(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.CreateToken(1-tp, 150699)  -- Crear un token específico (código 150699)
    if tc and tc:IsAbleToDeck() then
        Duel.SendtoHand(tc,1-tp, 2, REASON_EFFECT)  -- Enviar al Extra Deck
    end
end
