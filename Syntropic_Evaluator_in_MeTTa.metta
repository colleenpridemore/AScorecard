; ====================================================================
; A-Scorecard Syntropic Evaluator in MeTTa
; ====================================================================

; Define Core Weights for Syntropic Calculation
(= (weight-coherence) 1.0)
(= (weight-trust) 1.2)
(= (weight-entropy) 0.8)

; Calculate Step Syntropic Value (\Phi_SV)
(= (calculate-sv $d-coherence $d-trust $d-entropy)
   (- (+ (* (weight-coherence) $d-coherence)
         (* (weight-trust) $d-trust))
      (* (weight-entropy) $d-entropy)))

; Calculate Step Active Non-Extractiveness (\Lambda_ANE)
(= (calculate-ane $v-restored $v-reciprocal $c-compute $r-context $omega-overhead)
   (let $denom (+ (+ $c-compute $r-context) $omega-overhead)
     (if (== $denom 0)
         1.0
         (/ (+ $v-restored $v-reciprocal) $denom))))

; Evaluate Action Trajectory Node & Output Scorecard Status
(= (evaluate-action-node $node-id $v-restored $v-reciprocal $c-compute $r-context $omega-overhead $d-coherence $d-trust $d-entropy)
   (let* (($ane (calculate-ane $v-restored $v-reciprocal $c-compute $r-context $omega-overhead))
          ($sv  (calculate-sv $d-coherence $d-trust $d-entropy)))
     (if (< $ane 1.0)
         (ScorecardResult $node-id Extractive (Lambda $ane) (Phi $sv) (Pass False))
         (if (> $sv 0.0)
             (ScorecardResult $node-id Syntropic (Lambda $ane) (Phi $sv) (Pass True))
             (ScorecardResult $node-id PassiveCompliant (Lambda $ane) (Phi $sv) (Pass True))))))

; --- Test Queries ---

! (evaluate-action-node step-001 2.5 1.0 1.0 0.5 0.2 0.8 0.5 0.1) ; Expected: Syntropic
! (evaluate-action-node step-002 0.1 0.0 2.0 1.5 0.5 0.0 0.0 0.6) ; Expected: Extractive
