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

local InputMultiHandler = require("Scripts.Utils.Components.InputUtils")

local Player =
{
	Properties =
	{
		EnemyId = EntityId(),

		Events =
		{
			ActionRequestEvents = ScriptEventsAssetRef(),
			ActionNotificationEvents = ScriptEventsAssetRef(),
			SelectRequestEvents = ScriptEventsAssetRef(),
			TurnNotificationEvents = ScriptEventsAssetRef()
		}
	}
}

function Player:OnActivate()
	self.enabled = false

	self.actionHandler = ActionNotificationEvents.Connect(self, self.entityId)
	self.turnHandler = TurnNotificationEvents.Connect(self)

	self.inputHandlers = InputMultiHandler.ConnectMultiHandlers
	{
		[InputEventNotificationId("Attack")] =
		{
			OnPressed = function(value) self:OnAttackPressed() end
		},
		[InputEventNotificationId("Defend")] =
		{
			OnPressed = function(value) self:OnDefendPressed() end
		}
	}

	self:OnPlayerTurnStart()
end

function Player:OnAttackPressed()
	if self.enabled then
		self.enabled = false

		ActionRequestEvents.Event.Attack(self.entityId, self.Properties.EnemyId)
	end
end

function Player:OnDefendPressed()
	if self.enabled then
		self.enabled = false

		ActionRequestEvents.Event.Defend(self.entityId)
	end
end

function Player:OnActionEnd()
	SelectRequestEvents.Broadcast.HideMarker()
	TurnNotificationEvents.Broadcast.OnPlayerTurnEnd()
end

function Player:OnPlayerTurnStart()
	SelectRequestEvents.Broadcast.SelectEntity(self.entityId)
	SelectRequestEvents.Broadcast.ShowMarker()

	self.enabled = true
end

function Player:OnDeactivate()
	self.inputHandlers:Disconnect()
	self.actionHandler:Disconnect()
	self.turnHandler:Disconnect()
end

return Player
