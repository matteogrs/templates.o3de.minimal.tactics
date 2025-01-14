-- Copyright (c) 2025 Matteo Grasso
-- 
--     https://github.com/matteogrs/templates.o3de.minimal.tactics
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

local TimeDelay = require("Assets.Scripts.Utils.TimeDelay")

local Enemy =
{
	Properties =
	{
		Delay = 1.0,
		PlayerId = EntityId(),

		Events =
		{
			ActionRequestEvents = ScriptEventsAssetRef(),
			ActionNotificationEvents = ScriptEventsAssetRef(),
			SelectRequestEvents = ScriptEventsAssetRef(),
			TurnNotificationEvents = ScriptEventsAssetRef()
		}
	}
}

function Enemy:OnActivate()
	self.randomGenerator = Random()

	self.actionHandler = ActionNotificationEvents.Connect(self, self.entityId)
	self.turnHandler = TurnNotificationEvents.Connect(self)
end

function Enemy:OnActionEnd()
	SelectRequestEvents.Broadcast.HideMarker()
	TurnNotificationEvents.Broadcast.OnEnemyTurnEnd()
end

function Enemy:OnEnemyTurnStart()
	SelectRequestEvents.Broadcast.SelectEntity(self.entityId)
	SelectRequestEvents.Broadcast.ShowMarker()

	self.timer = TimeDelay:Start(self.Properties.Delay, function() self:OnDelayEnd() end)
end

function Enemy:OnDelayEnd()
	local choice = self.randomGenerator:GetRandomFloat()

	if choice > 0.5 then
		ActionRequestEvents.Event.Attack(self.entityId, self.Properties.PlayerId)
	else
		ActionRequestEvents.Event.Defend(self.entityId)
	end
end

function Enemy:OnDeactivate()
	self.turnHandler:Disconnect()
	self.actionHandler:Disconnect()

	if self.timer ~= nil then
		self.timer:Stop()
		self.timer = nil
	end
end

return Enemy
