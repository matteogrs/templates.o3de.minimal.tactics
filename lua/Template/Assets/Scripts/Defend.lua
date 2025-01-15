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

local Defend =
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

function Defend:OnActivate()
	self.actionHandler = ActionRequestEvents.Connect(self, self.entityId)
end

function Defend:Defend()
	local transform = TransformBus.Event.GetWorldTM(self.entityId)

	local minPosition = transform:GetTranslation()

	local forwardAxis = transform:GetBasisY()
	local maxPosition = minPosition - (forwardAxis * self.Properties.Offset)

	self.lerp = LerpBetween:StartWithSpeed(minPosition, maxPosition, self.Properties.Speed,
	{
		OnTick = function(value, percent) self:OnLerpTick(value, percent) end,
		OnCompleted = function() self:OnLerpCompleted() end
	})
end

function Defend:OnLerpTick(value, percent)
	TransformBus.Event.SetWorldTranslation(self.entityId, value)
end

function Defend:OnLerpCompleted()
	HealthRequestEvents.Event.SetShield(self.entityId)
	ActionNotificationEvents.Event.OnActionEnd(self.entityId)
end

function Defend:OnDeactivate()
	self.actionHandler:Disconnect()

	if self.lerp ~= nil then
		self.lerp:Cancel()
		self.lerp = nil
	end
end

return Defend
