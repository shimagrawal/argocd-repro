-- Custom apps/DaemonSet health check: Progressing only during a real rollout
-- (pods not yet on the latest spec), not while pods start on new nodes.
-- Trade-off: a pod stuck on a node (Pending, CrashLoopBackOff) reports Healthy.
hs = {}
if obj.status ~= nil then
  if obj.metadata.generation > (obj.status.observedGeneration or 0) then
    hs.status = "Progressing"
    hs.message = "Waiting for DaemonSet spec to be observed"
    return hs
  end
  if (obj.status.updatedNumberScheduled or 0) < (obj.status.desiredNumberScheduled or 0) then
    hs.status = "Progressing"
    hs.message = "DaemonSet rollout in progress"
    return hs
  end
end
hs.status = "Healthy"
return hs
