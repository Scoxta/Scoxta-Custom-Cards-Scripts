--- Hydro Paladin
local s,id=GetID()
function s.initial_effect(c)
    --synchro summon
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()
    -- Add card 
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(s.target)
    e1:SetCondition(s.effcon)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    --0 ATK while co-linked
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetCondition(s.atkcon)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
    -- Pendulum effect when destroyed
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCondition(s.pencon)
    e4:SetTarget(s.pentg)
    e4:SetOperation(s.penop)
    c:RegisterEffect(e4)
    -- Prevent destruction and damage, reduce opponent's monster ATK
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_ATKCHANGE)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_BATTLE_START)
    e5:SetRange(LOCATION_PZONE)
    --e5:SetCondition(s.atkcon2)
    e5:SetTarget(s.atktg2)
    e5:SetOperation(s.atkop2)
    c:RegisterEffect(e5)
    -- At the end of the Damage Step, reduce opponent's monster ATK
   local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,2))
    e6:SetCategory(CATEGORY_ATKCHANGE)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e6:SetCode(EVENT_DAMAGE_STEP_END)
    e6:SetRange(LOCATION_PZONE)
    e6:SetCondition(s.atkcon3)
    e6:SetOperation(s.atkop3)
    c:RegisterEffect(e6)
end
s.listed_series = {0x1F4}

function s.effcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.filter(c)
    return c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:GetLocation()==LOCATION_GRAVE and chkc:GetControler()==tp and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local a=Duel.GetAttacker()
    local b=Duel.GetAttackTarget()
    if not b then return false end
    if a:IsControler(1-tp) then a,b=b,a end
    return b and b:IsFaceup() and b:IsLevelBelow(c:GetLevel())
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local a=Duel.GetAttacker()
    local b=Duel.GetAttackTarget()
    if not b then return end
    if a:IsControler(1-tp) then a,b=b,a end
    if b and b:IsRelateToBattle() and b:IsFaceup() and b:IsControler(1-tp) and b:IsLevelBelow(c:GetLevel()) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
        e1:SetValue(0)
        b:RegisterEffect(e1)
    end
end

function s.pencon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsPreviousLocation(LOCATION_MZONE)
end

function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckPendulumZones(tp) end
end

function s.penop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.CheckPendulumZones(tp) then return end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end

function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    return (a and a:IsControler(tp) and a:IsSetCard(0x1F4)) or (d and d:IsControler(tp) and d:IsSetCard(0x1F4))
end

function s.Afilter(c)
    return c:IsFaceup() and c:IsFaceup(tp)
end
function s.Afilterw(c)
    return c:IsFaceup() 
end

function s.atktg2   (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.Afilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.Afilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.Afilter,tp,LOCATION_MZONE,0,1,1,nil)
end



function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        -- No puede ser destruido en esa batalla
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e1:SetValue(1)
        e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
        tc:RegisterEffect(e1)
        -- El daño de batalla que recibes es 0
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
        e2:SetValue(0)
        e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
        tc:RegisterEffect(e2)
    end
end

function s.atktg33(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,1-tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,Card.IsFaceup,1-tp,0,LOCATION_MZONE,1,1,nil)
end

function s.atkop34(e,tp,eg,ep,ev,re,r,rp,tc)
    if not tc or not tc:IsRelateToEffect(e) then return end
    local tg=Duel.GetFirstTarget()
    if not tg or not tg:IsRelateToEffect(e) then return end
    local lv=tc:GetLevel()
        local atk=lv * 44
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tg:RegisterEffect(e1)
end

function s.atkcon3(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    return a and a:IsRelateToBattle() and a:IsSetCard(0x1F4) and a:IsControler(tp)
end
function s.atkop3(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local a=Duel.GetAttacker()
    local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    local tc=tg:GetFirst()
    for tc in aux.Next(tg) do
        local atk=a:GetLevel() * 44
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end