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

local Attack =
{
	Properties =
	{
		Offset = 1.0,
		Speed = 3.0,

		Events =
		{
			ActionRequestEvents = ScriptEventsAssetRef(),
			ActionNotificationEvents = ScriptEventsAssetRef(),
			HealthRequestEvents = ScriptEventsAssetRef()
		}
	}
}

function Attack:OnActivate()
	self.actionHandler = ActionRequestEvents.Connect(self, self.entityId)
end

function Attack:Attack(targetId)
	local beforeMinPosition = TransformBus.Event.GetWorldTranslation(self.entityId)

	local maxPosition = TransformBus.Event.GetWorldTranslation(targetId)
	local distance = maxPosition - beforeMinPosition
	local direction = distance:GetNormalized()
	maxPosition = maxPosition - direction

	self.afterMinPosition = beforeMinPosition + (direction * self.Properties.Offset)
	self.targetId = targetId

	self.lerp = LerpBetween:StartWithSpeed(beforeMinPosition, maxPosition, self.Properties.Speed,
	{
		OnTick = function(value, percent) self:OnLerpTick(value, percent) end,
		OnCompleted = function() self:OnForwardLerpCompleted() end
	})
end

function Attack:OnLerpTick(value, percent)
	TransformBus.Event.SetWorldTranslation(self.entityId, value)
end

function Attack:OnForwardLerpCompleted()
	HealthRequestEvents.Event.DecreaseHealth(self.targetId)

	self.lerp = LerpBetween:StartWithSpeed(self.lerp.toValue, self.afterMinPosition, self.Properties.Speed,
	{
		OnTick = function(value, percent) self:OnLerpTick(value, percent) end,
		OnCompleted = function() self:OnBackwardLerpCompleted() end
	})
end

function Attack:OnBackwardLerpCompleted()
	ActionNotificationEvents.Event.OnActionEnd(self.entityId)
end

function Attack:OnDeactivate()
	self.actionHandler:Disconnect()

	if self.lerp ~= nil then
		self.lerp:Cancel()
		self.lerp = nil
	end
end

return Attack
