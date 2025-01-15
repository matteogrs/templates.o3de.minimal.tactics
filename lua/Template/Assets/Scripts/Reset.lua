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

local LerpBetween = require("Assets.Scripts.Utils.LerpBetween")

local Reset =
{
	Properties =
	{
		Enemy = false,
		Speed = 1.5,
		Tolerance = 0.01,

		Events =
		{
			TurnNotificationEvents = ScriptEventsAssetRef()
		}
	}
}

function Reset:OnActivate()
	self.restPosition = TransformBus.Event.GetLocalTranslation(self.entityId)

	self.turnHandler = TurnNotificationEvents.Connect(self)
end

function Reset:OnEnemyTurnEnd()
	if not self.Properties.Enemy then
		self:ClearPosition()
	end
end

function Reset:OnPlayerTurnEnd()
	if self.Properties.Enemy then
		self:ClearPosition()
	end
end

function Reset:ClearPosition()
	local position = TransformBus.Event.GetLocalTranslation(self.entityId)

	if position:GetDistance(self.restPosition) > self.Properties.Tolerance then
		self.lerp = LerpBetween:StartWithSpeed(position, self.restPosition, self.Properties.Speed,
		{
			OnTick = function(value, percent) self:OnLerpTick(value, percent) end,
			OnCompleted = function() self:OnLerpCompleted() end
		})
	else
		self:StartTurn()
	end
end

function Reset:OnLerpTick(value, percent)
	TransformBus.Event.SetLocalTranslation(self.entityId, value)
end

function Reset:OnLerpCompleted()
	self:StartTurn()
end

function Reset:StartTurn()
	if self.Properties.Enemy then
		TurnNotificationEvents.Broadcast.OnEnemyTurnStart()
	else
		TurnNotificationEvents.Broadcast.OnPlayerTurnStart()
	end
end

function Reset:OnDeactivate()
	self.turnHandler:Disconnect()

	if self.lerp ~= nil then
		self.lerp:Cancel()
		self.lerp = nil
	end
end

return Reset
